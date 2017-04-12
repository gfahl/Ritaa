module Ritaa
  class Polygon < Shape

    def initialize(graph)
      @points = graph.nodes.map { |node| [node.x * 5, node.y * 10] }
    end

    def max_x; @points.map { |x, y| x }.max; end
    def max_y; @points.map { |x, y| y }.max; end

    def to_element
      e = REXML::Element.new("polygon")
      e.attributes["points"] = @points.map { |x, y| "%d,%d" % [x, y] }.join(" ")
      e
    end

  end
end
