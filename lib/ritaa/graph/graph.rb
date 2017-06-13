module Ritaa
  class Graph # abstract
    attr_reader :nodes, :edges

    def initialize(edges = [])
      @nodes = []
      @edges = []
      edges.each do |e|
        _n1, _n2 = e.nodes
        m1, m2 = e.markers
        n1 = get_or_add_node(_n1.point)
        n2 = get_or_add_node(_n2.point)
        yield n1, n2, m1, m2
      end
    end

    def add_node(point)
      n = self.class::Node.new(point)
      @nodes << n
      n
    end

    def get_or_add_node(point)
      @nodes.find { |node| node.to_a == point.to_a } || add_node(point)
    end

    def inspect
      "{G: %s . %s}" % [@nodes.map(&:inspect).join(" "), @edges.map(&:inspect).join(" ")]
    end

    class Node # abstract
      attr_reader :point

      def initialize(point)
        @point = point
      end

      def inspect; "(N:%d,%d)" % to_a; end
      def to_a; [x, y]; end
      def x; @point.x; end
      def y; @point.y; end
    end

    class Edge # abstract
      attr_reader :nodes, :markers

      def initialize(node_1, node_2, marker_1 = nil, marker_2 = nil)
        @nodes = [node_1, node_2]
        @markers = [marker_1, marker_2]
      end

      def inspect; raise "%p must implement method %p" % [self.class, __method__]; end
    end
  end
end
