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

    def max_x; @points.map { |p| @image.convert_x_a2i(p) }.max; end
    def max_y; @points.map { |p| @image.convert_y_a2i(p) }.max; end

    def to_elements
      e = REXML::Element.new("polygon")
      res = [e]
      e.attributes["points"] = @points
        .map { |p| "%d,%d" % @image.convert_point_a2i(p).to_a }
        .join(" ")

      styles = []
      @properties.each do |k, v|
        case k
        when :id, :class, :z
          e.attributes[k.to_s] = v.to_s
        when :"drop-shadow" then nil
        else
          styles << "%s: %s" % [k, v]
        end
      end
      e.attributes["style"] = styles.join("; ") unless styles.empty?

      drop_shadow_style = @image.get_drop_shadow_class(
        @properties[:"drop-shadow"],
        @properties[:id],
        @properties[:class])
      if drop_shadow_style
        _e = REXML::Element.new("polygon")
        _e.attributes["points"] = e.attributes["points"]
        _e.attributes["class"] = drop_shadow_style
        _e.attributes["z"] = (e.attributes["z"] || 0).to_i - 1
        res << _e
      end

      res
    end
  end
end
