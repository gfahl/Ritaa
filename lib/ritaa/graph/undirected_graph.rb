module Ritaa
  class UndirectedGraph < Graph
    def initialize(edges = [])
      super { |n1, n2, m1, m2| add_line(n1, n2, m1, m2) }
    end

    def add_line(n1, n2, marker1 = nil, marker2 = nil)
      marker1 = nil if marker1 == '+'
      marker1 = :arrow if marker1 =~ /[<>\^v]/
      marker2 = nil if marker2 == '+'
      marker2 = :arrow if marker2 =~ /[<>\^v]/
      line = Line.new(n1, n2, marker1, marker2)
      n1.lines << line
      n2.lines << line
      @edges << line
      line
    end

    def remove_line(line)
      line.nodes.each do |node|
        node.lines.delete(line)
        @nodes.delete(node) if node.lines.empty?
      end
      @edges.delete(line)
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

      def initialize(point)
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
        prev, res = [], [self]
        while prev != res do
          prev = res
          res += res.map(&:neighbors).flatten
          res.uniq!
        end
        res
      end
    end

    class Line < Edge
      def inspect; "[E:%p%s-%p%s]" % [@nodes[0], @markers[0], @nodes[1], @markers[1]]; end

      def other_node(node)
        @nodes[0] == node ? @nodes[1] : @nodes[0]
      end
    end
  end
end
