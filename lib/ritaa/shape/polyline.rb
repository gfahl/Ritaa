module Ritaa
  class Polyline < Shape

    def initialize(graph)
      a = [graph.nodes.find { |node| node.degree == 1 }]
      (graph.nodes.size - 1).times do
        a << a.last.lines.map(&:nodes).flatten.find { |node| !a.include?(node) }
      end
      @coordinates = a.map { |node| node.to_a }
    end

    def max_x; @coordinates.map { |x, y| coord_to_point(x, y)[0] }.max; end
    def max_y; @coordinates.map { |x, y| coord_to_point(x, y)[1] }.max; end

    def to_element
      e = REXML::Element.new("polyline")
      e.attributes["points"] = @coordinates
        .map { |x, y| "%d,%d" % coord_to_point(x, y) }
        .join(" ")
      e
    end

  end
end
