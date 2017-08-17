module Ritaa
  class AsciiDiagram

    def initialize(dia, addendum, identifiers)
      @identifiers = []
      identifiers.each do |id|
        regex = Regexp.new("\\W" + id + "\\W")
        dia.each.with_index do |s, row|
          col = -1
          loop do
            col = (" " + s + " ").index(regex, col + 1)
            break unless col
            @identifiers << [col, row, id]
          end
        end
      end

      g = UndirectedGraph.new

      # nodes
      dia.each.with_index do |row, y|
        row.each_char.with_index do |ch, x|
          g.add_node(Point.new(x, y)) if ch =~ /[\+<>\^v]/
        end
      end
      sz = g.nodes.size

      # horizontal edges
      (0..3).map { |i| g.nodes.rotate(i) }.transpose.each do |n0, n1, n2, n3|
        next unless n1.y == n2.y
        if dia[n1.y][n1.x..n2.x].gsub("x", "-") =~ /^([+<])\-+([+>])$/
          n1 = n0 if n0.y == n1.y && dia[n1.y][n0.x..n1.x] == "+<"
          n2 = n3 if n2.y == n3.y && dia[n2.y][n2.x..n3.x] == ">+"
          g.add_line(n1, n2, $1, $2)
        end
      end
      # vertical edges
      transposed_dia = dia
        .map { |s| ("%-*s" % [dia.map(&:size).max, s]).split(//) }
        .transpose
        .map(&:join)
      _nodes = g.nodes.sort_by { |node| [node.x, node.y] }
      (0..3).map { |i| _nodes.rotate(i) }.transpose.each do |n0, n1, n2, n3|
        next unless n1.x == n2.x
        if transposed_dia[n1.x][n1.y..n2.y].gsub("x", "|") =~ /^([+^])\|+([+v])$/
          n1 = n0 if n0.x == n1.x && transposed_dia[n1.x][n0.y..n1.y] == "+^"
          n2 = n3 if n2.x == n3.x && transposed_dia[n2.x][n2.y..n3.y] == "v+"
          g.add_line(n1, n2, $1, $2)
        end
      end
      # additional edges specified outside diagram
      addendum.each do |s|
        h = JSON.parse(s[/^edge (.*)/, 1], symbolize_names: true)
        n1 = g.get_or_add_node(Point.new(h[:x1], h[:y1]))
        n2 = g.get_or_add_node(Point.new(h[:x2], h[:y2]))
        g.add_line(n1, n2, h[:marker1], h[:marker2])
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
      @faces_graph = DirectedGraph.new(undecided)
      @nonfaces_graph = UndirectedGraph.new(nonface_edges)
    end

    def to_shapes
      res = []

      # for the time being, always translate edges with marker(s) to Line elements
      # we may want to change this later
      @nonfaces_graph.lines.dup.each do |line|
        if line.markers != [nil, nil]
          res << Line.new(
            x1: line.nodes[0].x,
            y1: line.nodes[0].y,
            x2: line.nodes[1].x,
            y2: line.nodes[1].y,
            "arrow-start": line.markers[0] == :arrow,
            "arrow-end": line.markers[1] == :arrow
            )
          @nonfaces_graph.remove_line(line)
        end
      end

      res += @nonfaces_graph.components.map do |g|
        case g.nodes.map(&:degree).max
          when 1 then Line
          when 2 then Polyline
          else Path
        end.new(g)
      end

      used = {} # DirectedGraph::Arc => true
      while used.size < @faces_graph.arcs.size
        g = DirectedGraph.new
        angle_sum = 0
        arc = start_arc = @faces_graph.arcs.find { |a| !used[a] }
        loop do
          g.add_arc(
            g.get_or_add_node(arc.tail.point),
            g.get_or_add_node(arc.head.point))
          used[arc] = true
          candidates = arc.head.departing.select do |a|
            !used[a] && a.head != arc.tail || a == start_arc
          end
          next_arc = candidates.min_by { |a| DirectedGraph::Arc.angle(arc, a) }
          angle_sum += DirectedGraph::Arc.angle(arc, next_arc)
          break if next_arc == start_arc
          arc = next_arc
        end
        res << Polygon.new(g) if angle_sum < g.nodes.size * 180
      end

      res.select do |shape|
        s = shape.find_identifier(@identifiers)
        case s
          when /^[A-Z]/ then shape.properties[:id] = s
          when /^[a-z]/ then shape.properties[:class] = s
        end
        s != "nil"
      end
    end

    class Point < Ritaa::Point; end
  end
end
