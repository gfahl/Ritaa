module Ritaa
  class Polyline < Shape
    def initialize(arg)
      @properties, @points =
        case arg
          when Hash
            points = arg.delete(:points)
            [arg, points.split(" ").map { |s| AsciiDiagram::Point.new(*s.split(",").map(&:to_i)) }]
          when UndirectedGraph
            nodes = [arg.nodes.find { |node| node.degree == 1 }]
            (arg.nodes.size - 1).times do
              nodes << nodes.last.lines.map(&:nodes).flatten.find { |node| !nodes.include?(node) }
            end
            [{}, nodes.map(&:point)]
        end
    end

    def max_x; @points.map { |p| Image::Point.new(p).x }.max; end
    def max_y; @points.map { |p| Image::Point.new(p).y }.max; end

    def to_elements
      e = REXML::Element.new("polyline")
      e.attributes["points"] = @points
        .map { |p| "%d,%d" % Image::Point.new(p).to_a }
        .join(" ")
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
      [e]
    end
  end
end
