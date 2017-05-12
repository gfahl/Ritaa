module Ritaa
  class Line < Shape

    def initialize(arg = nil)
      @properties, @coordinates =
        case arg
          when Hash
            x1 = arg.delete(:x1)
            y1 = arg.delete(:y1)
            x2 = arg.delete(:x2)
            y2 = arg.delete(:y2)
            [arg, [[x1, y1], [x2, y2]]]
          when UndirectedGraph
            [{}, arg.nodes.map { |node| node.to_a }]
        end
    end

    def max_x; @coordinates.map { |x, y| coord_to_point(x, y)[0] }.max; end
    def max_y; @coordinates.map { |x, y| coord_to_point(x, y)[1] }.max; end

    def to_element
      e = REXML::Element.new("line")
      e.attributes["x1"], e.attributes["y1"] = coord_to_point(*@coordinates[0])
      e.attributes["x2"], e.attributes["y2"] = coord_to_point(*@coordinates[1])
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
