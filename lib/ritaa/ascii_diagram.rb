module Ritaa
  class AsciiDiagram
    def initialize(dia, addendum)
      g = UndirectedGraph.new

      # nodes
      dia.each.with_index do |row, y|
        row.each_char.with_index do |ch, x|
          g.add_node(Point.new(x, y)) if ch == "+"
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
        n1 = g.get_or_add_node(Point.new(h[:x1], h[:y1]))
        n2 = g.get_or_add_node(Point.new(h[:x2], h[:y2]))
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
      @faces_graph = DirectedGraph.new(undecided)
      @nonfaces_graph = UndirectedGraph.new(nonface_edges)
    end

    def to_shapes
      res = @nonfaces_graph.components.map do |g|
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

      res
    end

    class Point < Ritaa::Point; end
  end
end
