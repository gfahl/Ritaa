module Ritaa
  class Polyline < Shape
    def initialize(graph)
      nodes = [graph.nodes.find { |node| node.degree == 1 }]
      (graph.nodes.size - 1).times do
        nodes << nodes.last.lines.map(&:nodes).flatten.find { |node| !nodes.include?(node) }
      end
      @points = nodes.map(&:point)
    end

    def max_x; @points.map { |p| Image::Point.new(p).x }.max; end
    def max_y; @points.map { |p| Image::Point.new(p).y }.max; end

    def to_element
      e = REXML::Element.new("polyline")
      e.attributes["points"] = @points
        .map { |p| "%d,%d" % Image::Point.new(p).to_a }
        .join(" ")
      e
    end
  end
end
