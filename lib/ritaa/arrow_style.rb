class ArrowStyle

  attr_reader :id

  def initialize(h)
    @h = h
    @id = @h.delete(:id)
    @id = @id ? @id.to_i : 0
  end

  def adjust_end_point(point, other_point)
    x1, y1 = point.to_a
    x2, y2 = other_point.to_a
    x, y = x2 - x1, y2 - y1
    l = Math.sqrt(x.abs ** 2 + y.abs ** 2)
    dx = @h[:width] / 2.0 * (x / l)
    dy = @h[:width] / 2.0 * (y / l)
    dx = dx.to_i if dx.to_i == dx
    dy = dy.to_i if dy.to_i == dy
    Ritaa::Image::Point.new(x1 + dx, y1 + dy)
  end

  def to_elements
    half_width = @h[:width] / 2.0
    half_width = half_width.to_i if half_width.to_i == half_width
    half_height = @h[:height] / 2.0
    half_height = half_height.to_i if half_height.to_i == half_height
    %w{end start}.map do |pos|
      elm_marker = REXML::Element.new("marker")
      elm_marker.attributes["id"] = "arrow_%d_%s" % [id, pos]
      elm_marker.attributes["refX"] = half_width
      elm_marker.attributes["refY"] = half_height
      elm_marker.attributes["markerUnits"] = "userSpaceOnUse"
      elm_marker.attributes["markerWidth"] = @h[:width]
      elm_marker.attributes["markerHeight"] = @h[:height]
      elm_marker.attributes["orient"] = "auto"
      e = REXML::Element.new("path")
      elm_marker.add_element(e)
      e.attributes["d"] = "M%s,%s L%s,%s L%s,%s Z" %
        if pos == "end"
          [0, 0, @h[:width], half_height, 0, @h[:height]]
        else
          [@h[:width], 0, 0, half_height, @h[:width], @h[:height]]
        end
      e.attributes["style"] = "fill: %s; stroke: none" % @h[:color]
      elm_marker
    end
  end

end
