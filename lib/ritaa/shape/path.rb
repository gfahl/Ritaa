module Ritaa
  class Path < Shape

    def initialize(graph)
      lines = []
      node = graph.nodes.find { |node| node.degree == 1 }
      edge = node.lines[0]
      queue = [[node, edge]]
      while !queue.empty? do
        current_node, current_edge = queue.shift
        line = [current_node]
        loop do
          next_node = current_edge.other_node(current_node)
          line << next_node
          next_edges = next_node.lines - [current_edge]
          next_edge = next_edges.first
          break unless next_edge
          queue += next_edges[1..-1].map { |e| [next_node, e] }
          current_node, current_edge = next_node, next_edge
        end
        lines << line
      end
      @instructions = lines
        .map { |nodes| nodes.map { |node| [node.x * 5, node.y * 10] } }
        .map { |first, *rest| ["M %d,%d" % first] + rest.map { |x, y| "L %d,%d" % [x, y] } }
        .flatten
    end

    def max_x; @instructions.map { |s| s[/\w (\d+),\d+/, 1].to_i }.max; end
    def max_y; @instructions.map { |s| s[/\w \d+,(\d+)/, 1].to_i }.max; end

    def to_element
      e = REXML::Element.new("path")
      e.attributes["d"] = @instructions.join(" ")
      e
    end

  end
end
