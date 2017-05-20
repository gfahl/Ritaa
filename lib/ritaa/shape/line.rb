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

    def max_x; @points.map { |p| Image::Point.new(p).x }.max; end
    def max_y; @points.map { |p| Image::Point.new(p).y }.max; end

    def to_element
      e = REXML::Element.new("line")
      p1, p2 = @points.map { |p| Image::Point.new(p) }
      e.attributes["x1"], e.attributes["y1"] = p1.to_a
      e.attributes["x2"], e.attributes["y2"] = p2.to_a
      styles = []
      @properties.each do |k, v|
        case k
        when :id, :z
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
