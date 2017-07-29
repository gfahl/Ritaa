module Ritaa
  class Path < Shape
    def initialize(arg)
      @properties, @lines =
        case arg
          when Hash
            instructions = arg.delete(:d)
            [arg, instructions
              .split(/ (?=M)/)
              .map do |s|
                s.scan(/\d+,\d+/).map do |s|
                  AsciiDiagram::Point.new(*s.split(",").map(&:to_i))
                end
              end]
          when UndirectedGraph
            lines = []
            node = arg.nodes.find { |node| node.degree == 1 }
            edge = node.lines[0]
            queue = [[node, edge]]
            while !queue.empty? do
              current_node, current_edge = queue.shift
              nodes = [current_node]
              loop do
                next_node = current_edge.other_node(current_node)
                nodes << next_node
                next_edges = next_node.lines - [current_edge]
                next_edge = next_edges.shift
                break unless next_edge
                queue += next_edges.map { |e| [next_node, e] }
                current_node, current_edge = next_node, next_edge
              end
              lines << nodes.map(&:point)
            end
            [{}, lines]
        end
    end

    def max_x; @lines.flatten(1).map { |p| @image.convert_x_a2i(p) }.max; end
    def max_y; @lines.flatten(1).map { |p| @image.convert_y_a2i(p) }.max; end

    def to_elements
      e = REXML::Element.new("path")
      e.attributes["d"] = @lines
        .map { |points| points.map { |p| @image.convert_point_a2i(p).to_a } }
        .map { |first, *rest| ["M %d,%d" % first] + rest.map { |x, y| "L %d,%d" % [x, y] } }
        .flatten
        .join(" ")
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
