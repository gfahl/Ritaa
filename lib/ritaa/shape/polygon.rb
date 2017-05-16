module Ritaa
  class Polygon < Shape
    attr_reader :properties

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

    def find_identifier(identifiers)
      res = identifiers.find do |x, y, s|
        # ray-casting algorithm
        inside = false
        @points.zip(@points.rotate).each do |p1, p2|
          p1, p2 = p2, p1 if p1.y > p2.y
          x1, y1 = p1.x, p1.y
          x2, y2 = p2.x, p2.y
          if y1 < y && y2 > y && x1 + (x2 - x1) * (y - y1) / (y2 - y1) > x
            # the line from p1 to p2 intersects with an infinite line from (x, y) rightwards
            inside = !inside
          end
        end
        inside
      end
      res && res[2]
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
        when :id, :class
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
