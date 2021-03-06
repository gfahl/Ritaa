module Ritaa
  class Line < Shape
    def initialize(arg = nil)
      @properties, @points =
        case arg
          when Hash
            x1 = arg.delete(:x1)
            y1 = arg.delete(:y1)
            x2 = arg.delete(:x2)
            y2 = arg.delete(:y2)
            [arg, [AsciiDiagram::Point.new(x1, y1), AsciiDiagram::Point.new(x2, y2)]]
          when UndirectedGraph
            [{}, arg.nodes.map(&:point)]
        end
    end

    def find_identifier(identifiers)
      res = identifiers.find do |x, y, s|
        p1, p2 = @points
        x1, y1 = p1.x, p1.y
        x2, y2 = p2.x, p2.y
        dx = s.size - 1
        if y1 == y2
          x1, x2 = [x1, x2].sort
          (y - y1).abs == 1 && x + dx > x1 && x < x2
        elsif x1 == x2
          y1, y2 = [y1, y2].sort
          y > y1 && y < y2 && (x + dx == x1 - 1 || x == x1 + 1)
        end
      end
      res && res[2]
    end

    def max_x; @points.map { |p| @image.convert_x_a2i(p) }.max; end
    def max_y; @points.map { |p| @image.convert_y_a2i(p) }.max; end

    def to_elements
      e = REXML::Element.new("line")
      p1, p2 = @points.map { |p| @image.convert_point_a2i(p) }
      arrow_styles = @image.get_arrow_styles(
        @properties[:"arrow-start"],
        @properties[:"arrow-end"],
        @properties[:id],
        @properties[:class])
      p1 = arrow_styles[0].adjust_end_point(p1, p2) if arrow_styles[0]
      p2 = arrow_styles[1].adjust_end_point(p2, p1) if arrow_styles[1]
      e.attributes["x1"], e.attributes["y1"] = p1.to_a
      e.attributes["x2"], e.attributes["y2"] = p2.to_a

      if arrow_styles[0]
        e.attributes["marker-start"] = "url(#arrow_%d_start)" % arrow_styles[0].id
      end
      if arrow_styles[1]
        e.attributes["marker-end"] = "url(#arrow_%d_end)" % arrow_styles[1].id
      end

      styles = []
      @properties.each do |k, v|
        case k
        when :id, :class, :z
          e.attributes[k.to_s] = v.to_s
        when :"arrow-start", :"arrow-end" then nil
        else
          styles << "%s: %s" % [k, v]
        end
      end
      e.attributes["style"] = styles.join("; ") unless styles.empty?

      [e]
    end
  end
end
