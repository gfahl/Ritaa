module Ritaa
  class Shape # abstract
    def max_x; raise "%p must implement method %p" % [self.class, __method__]; end
    def max_y; raise "%p must implement method %p" % [self.class, __method__]; end
    def to_element; raise "%p must implement method %p" % [self.class, __method__]; end
  end
end
