module Ritaa
  class Polygon < Shape

    def initialize(arg = nil)
      @properties, @coordinates =
        case arg
          when Hash
            points = arg.delete(:points)
            [arg, points.split(" ").map { |s| s.split(",").map(&:to_i) }]
          when DirectedGraph
            [{}, arg.nodes.map { |node| node.to_a }]
        end
    end

    def max_x; @coordinates.map { |x, y| coord_to_point(x, y)[0] }.max; end
    def max_y; @coordinates.map { |x, y| coord_to_point(x, y)[1] }.max; end

    def to_element
      e = REXML::Element.new("polygon")
      e.attributes["points"] = @coordinates
        .map { |x, y| "%d,%d" % coord_to_point(x, y) }
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
