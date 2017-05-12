module Ritaa
  class Shape # abstract
    attr_writer :image
    def coord_to_point(x, y); @image.coord_to_point(x, y); end
    def max_x; raise "%p must implement method %p" % [self.class, __method__]; end
    def max_y; raise "%p must implement method %p" % [self.class, __method__]; end
    def to_element; raise "%p must implement method %p" % [self.class, __method__]; end
  end
end
