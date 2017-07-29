module Ritaa
  class Rect < Shape
    def initialize(arg = nil)
      @properties, @top_left, @bottom_right =
        case arg
          when Hash
            x = arg.delete(:x)
            y = arg.delete(:y)
            width = arg.delete(:width)
            height = arg.delete(:height)
            [arg, AsciiDiagram::Point.new(x, y), AsciiDiagram::Point.new(x + width, y + height)]
        end
    end

    def max_x; @image.convert_x_a2i(@bottom_right); end
    def max_y; @image.convert_y_a2i(@bottom_right); end

    def to_elements
      e = REXML::Element.new("rect")
      x, y = @image.convert_point_a2i(@top_left).to_a
      x2, y2 = @image.convert_point_a2i(@bottom_right).to_a
      e.attributes["x"], e.attributes["y"] = x, y
      e.attributes["width"], e.attributes["height"] = x2 - x, y2 - y
      styles = []
      @properties.each do |k, v|
        case k
        when :id, :z
          e.attributes[k.to_s] = v.to_s
        else
          styles << "%s: %s" % [k, v]
        end
      end
      e.attributes["style"] = styles.join("; ") unless styles.empty?
      [e]
    end
  end
end
