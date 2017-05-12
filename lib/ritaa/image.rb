module Ritaa
  class Image
    def initialize(spec)
      ix = spec.find_index { |s| s =~ /^\w/ }
      dia, rest = spec[0...ix], spec[ix..-1]
      addendum, shapes_and_styles = rest.partition { |s| s =~ /^edge / }
      @properties = {}
      @shapes = []
      @styles = { line: {}, polygon: {}, polyline: {}, path: {} }
      parse_diagram(dia, addendum)
      parse_shapes_and_styles(shapes_and_styles)
    end

    def add_shape(shape)
      @shapes << shape
      shape.image = self
    end

    def coord_to_point(x, y)
      [x * 5, y * 10]
    end

    def height
      @properties[:height] || @shapes.map(&:max_y).max
    end

    def margin_bottom; @properties[:"margin-bottom"] || 0; end
    def margin_left; @properties[:"margin-left"] || 0; end
    def margin_right; @properties[:"margin-right"] || 0; end
    def margin_top; @properties[:"margin-top"] || 0; end

    def parse_diagram(dia, addendum)
      g = UndirectedGraph.new

      # nodes
      dia.each.with_index do |row, y|
        row.each_char.with_index do |ch, x|
          g.add_node(x, y) if ch == "+"
        end
      end
      sz = g.nodes.size

      # horizontal edges
      g.nodes[0..sz - 2].zip(g.nodes[1..sz - 1]).each do |n1, n2|
        if n1.y == n2.y && dia[n1.y][n1.x..n2.x] =~ /^\+\-+\+$/
          g.add_line(n1, n2)
        end
      end
      # vertical edges
      transposed_dia = dia
        .map { |s| ("%-*s" % [dia.map(&:size).max, s]).split(//) }
        .transpose
        .map(&:join)
      _nodes = g.nodes.sort_by { |node| [node.x, node.y] }
      _nodes[0..sz - 2].zip(_nodes[1..sz - 1]).each do |n1, n2|
        if n1.x == n2.x && transposed_dia[n1.x][n1.y..n2.y] =~ /^\+\|+\+$/
          g.add_line(n1, n2)
        end
      end
      # additional edges specified outside diagram
      addendum.each do |s|
        h = JSON.parse(s[/^edge (.*)/, 1], symbolize_names: true)
        n1 = g.get_or_add_node(h[:x1], h[:y1])
        n2 = g.get_or_add_node(h[:x2], h[:y2])
        g.add_line(n1, n2)
      end

      # split graph into two: one for faces and one for non-faces
      undecided = g.lines
      nonface_edges = []
      loop do
        end_edges, undecided = undecided.partition do |e|
          e.nodes[0].lines.select { |_e| undecided.include?(_e) } == [e] ||
          e.nodes[1].lines.select { |_e| undecided.include?(_e) } == [e]
        end
        break if end_edges.empty?
        nonface_edges += end_edges
      end
      face_graph = DirectedGraph.new(undecided)
      nonface_graph = UndirectedGraph.new(nonface_edges)

      # create shapes for non-faces
      nonface_graph.components.each do |g|
        add_shape(
          case g.nodes.map(&:degree).max
            when 1 then Line
            when 2 then Polyline
            else Path
          end.new(g))
      end

      # create polygons for faces
      used = {} # Arc => true
      while used.size < face_graph.arcs.size
        g = DirectedGraph.new
        angle_sum = 0
        arc = start_arc = face_graph.arcs.find { |a| !used[a] }
        loop do
          g.add_arc(
            g.get_or_add_node(arc.tail.x, arc.tail.y),
            g.get_or_add_node(arc.head.x, arc.head.y))
          used[arc] = true
          candidates = arc.head.departing.select do |a|
            !used[a] && a.head != arc.tail || a == start_arc
          end
          next_arc = candidates.min_by { |a| DirectedGraph::Arc.angle(arc, a) }
          angle_sum += DirectedGraph::Arc.angle(arc, next_arc)
          break if next_arc == start_arc
          arc = next_arc
        end
        add_shape(Polygon.new(g)) if angle_sum < g.nodes.size * 180
      end
    end

    def parse_shapes_and_styles(shapes_and_styles)
      shapes_and_styles.each do |s|
        case s
          when /^(L\d+) (.*)/
            h_shape, h_style = JSON.parse($2, symbolize_names: true)
              .partition { |k, v| [:x1, :y1, :x2, :y2].include?(k) }
              .map(&:to_h)
            add_shape(Line.new(h_shape.merge(id: $1)))
            @styles["#" + $1] = h_style
          when /^(P\d+) (.*)/
            h_shape, h_style = JSON.parse($2, symbolize_names: true)
              .partition { |k, v| [:points].include?(k) }
              .map(&:to_h)
            add_shape(Polygon.new(h_shape.merge(id: $1)))
            @styles["#" + $1] = h_style
          when /^line (.*)/
            add_shape(Line.new(JSON.parse($1, symbolize_names: true)))
          when /^polygon (.*)/
            add_shape(Polygon.new(JSON.parse($1, symbolize_names: true)))
          when /^image (.*)/
            h = JSON.parse($1, symbolize_names: true)
            margin = h.delete(:margin)
            h.merge!(
              "margin-bottom": margin,
              "margin-left": margin,
              "margin-right": margin,
              "margin-top": margin
              ) if margin
            @properties.merge!(h)
          when /^(line|polyline|polygon|path)s (.*)/
            h = JSON.parse($2, symbolize_names: true)
            @styles[$1.to_sym].merge!(h)
        end
      end
    end

    def to_svg
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new("1.0", "UTF-8")
      root = REXML::Element.new("svg")
      doc.add_element(root)
      root.attributes["xmlns"] = "http://www.w3.org/2000/svg"
      root.attributes["version"] = "1.1"
      root.attributes["width"] = total_width.to_s
      root.attributes["height"] = total_height.to_s
      root.attributes["viewBox"] =
        "%d %d %d %d" % [-margin_left, -margin_top, total_width, total_height]
      h = @properties.reject { |k, v| k =~ /^margin\-/ }
      unless h.empty?
        root.attributes["style"] = h.map { |k, v| "%s: %s" % [k, v] }.join("; ")
      end

      e = REXML::Element.new("style")
      root.add_element(e)
      @styles.each do |shape_type, h|
        unless h.empty?
          s = "%s { %s }" % [shape_type, h.map { |k, v| "%s: %s" % [k, v] }.join("; ")]
          e.add_text(REXML::Text.new(s))
        end
      end

      @shapes.each { |shape| root.add_element(shape.to_element) }

      res = ""; doc.write(res, 2); res
    end

    def total_height; margin_top + height + margin_bottom; end
    def total_width; margin_left + width + margin_right; end

    def width
      @properties[:height] || @shapes.map(&:max_x).max
    end
  end
end
