module Ritaa
  class SizeManager
    def initialize(default_row_size, default_column_size)
      @default_row_size, @default_column_size = default_row_size, default_column_size
      @size_exceptions = { "r" => {}, "c" => {} }
        # example: a size exception "c0-3": "150pt" will give these entries:
        # { "r" => {}, "c" => { 0 => 50, 1 => 50, 2 => 50 } }
      @x, @y = [0], [0]
    end

    def add_sizes(h)
      h.each do |k, v|
        case k
          when "row", "col", "column"
          when "row"
            @default_row_size = parse_size(v)
          when "column", "col"
            @default_column_size = parse_size(v)
          when /^(r|c)((\d+\-\d+)(,\d+\-\d+)*)/
            type, ixs = $1, $2
            size = parse_size(v)
            ixs.split(",").each do |s|
              ix1, ix2 = s.split("-").map(&:to_i).sort
              (ix1...ix2).each do |r|
                @size_exceptions[type][r] = size / (ix2 - ix1)
              end
            end
          else raise "Unexpected size key: %p" % k
        end
      end
    end

    def convert_point_a2i(p)
      Image::Point.new(convert_x_a2i(p), convert_y_a2i(p))
    end

    def convert_x_a2i(p)
      (@x.size..p.x).each do |i|
        @x[i] = @x[i - 1] + (@size_exceptions["c"][i - 1] || @default_column_size)
      end
      @x[p.x]
    end

    def convert_y_a2i(p)
      (@y.size..p.y).each do |i|
        @y[i] = @y[i - 1] + (@size_exceptions["r"][i - 1] || @default_row_size)
      end
      @y[p.y]
    end

    def parse_size(s)
      size = s[/^(\d+)pt$/, 1]
      raise "Unexpected size value: %p" % v unless size
      size.to_i
    end
  end
end
