module Ritaa
  class Line < Shape

    def initialize(arg = nil)
      h =
        case arg
          when Hash then arg
          when UndirectedGraph
            [:x1, :y1, :x2, :y2].zip(arg.nodes.map(&:to_a).flatten).to_h
        end
      h[:x1] *= 5
      h[:y1] *= 10
      h[:x2] *= 5
      h[:y2] *= 10
      @properties = h
    end

    def max_x; [@properties[:x1], @properties[:x2]].max; end
    def max_y; [@properties[:y1], @properties[:y2]].max; end

    def to_element
      e = REXML::Element.new("line")
      styles = []
      @properties.each do |k, v|
        case k
        when :id, :x1, :y1, :x2, :y2
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
