module Ritaa
  class Path < Shape
    def initialize(graph)
      @lines = []
      node = graph.nodes.find { |node| node.degree == 1 }
      edge = node.lines[0]
      queue = [[node, edge]]
      while !queue.empty? do
        current_node, current_edge = queue.shift
        nodes = [current_node]
        loop do
          next_node = current_edge.other_node(current_node)
          nodes << next_node
          next_edges = next_node.lines - [current_edge]
          next_edge = next_edges.shift
          break unless next_edge
          queue += next_edges.map { |e| [next_node, e] }
          current_node, current_edge = next_node, next_edge
        end
        @lines << nodes.map(&:point)
      end
    end

    def max_x; @lines.flatten(1).map { |p| Image::Point.new(p).x }.max; end
    def max_y; @lines.flatten(1).map { |p| Image::Point.new(p).y }.max; end

    def to_element
      e = REXML::Element.new("path")
      e.attributes["d"] = @lines
        .map { |points| points.map { |p| Image::Point.new(p).to_a } }
        .map { |first, *rest| ["M %d,%d" % first] + rest.map { |x, y| "L %d,%d" % [x, y] } }
        .flatten
        .join(" ")
      e
    end
  end
end
