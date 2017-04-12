module Ritaa
  class Polyline < Shape

    def initialize(graph)
      a = [graph.nodes.find { |node| node.degree == 1 }]
      (graph.nodes.size - 1).times do
        a << a.last.lines.map(&:nodes).flatten.find { |node| !a.include?(node) }
      end
      @points = a.map { |node| [node.x * 5, node.y * 10] }
    end

    def max_x; @points.map { |x, y| x }.max; end
    def max_y; @points.map { |x, y| y }.max; end

    def to_element
      e = REXML::Element.new("polyline")
      e.attributes["points"] = @points.map { |x, y| "%d,%d" % [x, y] }.join(" ")
      e
    end

  end
end
