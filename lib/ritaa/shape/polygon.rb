module Ritaa
  class Polygon < Shape

    def initialize(arg = nil)
      case arg
        when Hash
          @properties = arg
          coordinates = @properties
            .delete(:points)
            .split(" ")
            .map { |s| s.split(",").map(&:to_i) }
        when DirectedGraph
          @properties = {}
          coordinates = arg.nodes.map { |node| [node.x, node.y] }
      end
      @points = coordinates.map { |x, y| [x * 5, y * 10] }
    end

    def max_x; @points.map { |x, y| x }.max; end
    def max_y; @points.map { |x, y| y }.max; end

    def to_element
      e = REXML::Element.new("polygon")
      e.attributes["points"] = @points.map { |x, y| "%d,%d" % [x, y] }.join(" ")
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
