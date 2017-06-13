module Ritaa
  class DirectedGraph < Graph
    def initialize(edges = [])
      super { |n1, n2, m1, m2| add_arc(n1, n2); add_arc(n2, n1) }
    end

    def add_arc(n1, n2)
      arc = Arc.new(n1, n2)
      n1.departing << arc
      n2.arriving << arc
      @edges << arc
      arc
    end

    def arcs; @edges; end

    class Node < Graph::Node
      attr_reader :departing, :arriving

      def initialize(point)
        super
        @departing = []
        @arriving = []
      end

      def indegree; @arriving.size; end
      def outdegree; @departing.size; end
    end

    class Arc < Edge
      def self.angle(arc1, arc2)
        (arc2.angle + 180 - arc1.angle) % 360
      end

      def angle
        x1, y1 = tail.to_a
        x2, y2 = head.to_a
        x = x2 - x1
        y = y2 - y1
        (Math.atan2(-y, x) * 180 / Math::PI) % 360
      end

      def head; nodes[1]; end
      def inspect; "[E:%p->%p]" % @nodes; end
      def tail; nodes[0]; end
    end
  end
end
