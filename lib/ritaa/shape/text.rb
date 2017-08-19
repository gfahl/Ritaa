module Ritaa
  class Text < Shape
    def initialize(h)
      @point = AsciiDiagram::Point.new(h.delete(:x), h.delete(:y))
      @properties = h
    end

    def find_identifier(identifiers); nil; end

    def max_x; @image.convert_x_a2i(@point); end
    def max_y; @image.convert_y_a2i(@point); end

    def text; @properties[:text]; end

    def to_elements
      e = REXML::Element.new("text")
      e.add_text(REXML::Text.new(text))
      p1 = @image.convert_point_a2i(@point)
      e.attributes["x"], e.attributes["y"] = p1.to_a

      styles = []
      @properties.each do |k, v|
        case k
        when :id, :class, :z
          e.attributes[k.to_s] = v.to_s
        when :text then nil
        else
          styles << "%s: %s" % [k, v]
        end
      end
      e.attributes["style"] = styles.join("; ") unless styles.empty?

      [e]
    end
  end
end
