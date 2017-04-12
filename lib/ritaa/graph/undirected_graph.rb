module Ritaa
  class UndirectedGraph < Graph
    def initialize(edges = [])
      super { |n1, n2| add_line(n1, n2) }
    end

    def add_line(n1, n2)
      line = Line.new(n1, n2)
      n1.lines << line
      n2.lines << line
      @edges << line
      line
    end

    def components
      node_sets = []
      loop do
        n = @nodes.find { |_n| !node_sets.flatten.include?(_n) }
        break unless n
        node_sets << n.reachable
      end
      node_sets.map do |nodes|
        UndirectedGraph.new(nodes.map(&:lines).flatten.uniq)
      end
    end

    def lines; @edges; end

    class Node < Graph::Node
      attr_reader :lines

      def initialize(x, y)
        super
        @lines = []
      end

      def degree; @lines.size; end

      def isolated?; degree == 0; end
      def leaf?; degree == 1; end

      def neighbors
        @lines.map(&:nodes).flatten.uniq
      end

      def reachable
        prev, res = nil, [self]
        while prev != res do
          prev = res
          res = res.map(&:neighbors).flatten.uniq
        end
        res
      end
    end

    class Line < Edge
      def inspect; "[E:%p-%p]" % @nodes; end

      def other_node(node)
        @nodes[0] == node ? @nodes[1] : @nodes[0]
      end
    end
  end
end
