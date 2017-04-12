module Ritaa
  class Graph # abstract
    attr_reader :nodes, :edges

    def initialize(edges = [])
      @nodes = []
      @edges = []
      edges.each do |e|
        _n1, _n2 = e.nodes
        n1 = get_or_add_node(_n1.x, _n1.y)
        n2 = get_or_add_node(_n2.x, _n2.y)
        yield n1, n2
      end
    end

    def add_node(x, y)
      n = self.class::Node.new(x, y)
      @nodes << n
      n
    end

    def get_or_add_node(x, y)
      @nodes.find { |node| node.x == x && node.y == y } || add_node(x, y)
    end

    def inspect
      "{G: %s . %s}" % [@nodes.map(&:inspect).join(" "), @edges.map(&:inspect).join(" ")]
    end

    class Node # abstract
      attr_reader :x, :y

      def initialize(x, y)
        @x, @y = x, y
      end

      def inspect; "(N:%d,%d)" % [@x, @y]; end
      def to_a; [@x, @y]; end
    end

    class Edge # abstract
      attr_reader :nodes

      def initialize(node_1, node_2)
        @nodes = [node_1, node_2]
      end

      def inspect; raise "%p must implement method %p" % [self.class, __method__]; end
    end
  end
end
