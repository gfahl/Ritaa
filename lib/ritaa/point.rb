module Ritaa
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def to_a; [@x, @y]; end
  end
end
