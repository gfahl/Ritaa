module Ritaa
  class Polygon < Shape
    def initialize(arg = nil)
      @properties, @points =
        case arg
          when Hash
            points = arg.delete(:points)
            [arg, points.split(" ").map { |s| AsciiDiagram::Point.new(*s.split(",").map(&:to_i)) }]
          when DirectedGraph
            [{}, arg.nodes.map(&:point)]
        end
    end

    def max_x; @points.map { |p| Image::Point.new(p).x }.max; end
    def max_y; @points.map { |p| Image::Point.new(p).y }.max; end

    def to_element
      e = REXML::Element.new("polygon")
      e.attributes["points"] = @points
        .map { |p| "%d,%d" % Image::Point.new(p).to_a }
        .join(" ")
      styles = []
      @properties.each do |k, v|
        case k
        when :id
          e.attributes[k.to_s] = @properties[k].to_s
        else
          styles << "%s: %s" % [k, v]
        end
      end
      e.attributes["style"] = styles.join("; ") unless styles.empty?
      e
    end
  end
end
