module Ritaa
  class Shape # abstract
    attr_reader :properties
    attr_writer :image
    def find_identifier(identifiers); raise "%p must implement method %p" % [self.class, __method__]; end
    def max_x; raise "%p must implement method %p" % [self.class, __method__]; end
    def max_y; raise "%p must implement method %p" % [self.class, __method__]; end
    def to_elements; raise "%p must implement method %p" % [self.class, __method__]; end
  end
end
