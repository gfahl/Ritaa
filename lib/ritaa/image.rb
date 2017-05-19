module Ritaa
  class Image
    RESERVED_WORDS = %w(
      line path polygon polyline
      lines paths polygons polylines
      edge image nil)

    def Image.extract_identifiers(shapes_and_styles)
      shapes_and_styles.map { |s| s[/^\w+/] }.uniq - RESERVED_WORDS + ["nil"]
    end

    def initialize(spec)
      ix = spec.find_index { |s| s =~ /^\w/ }
      graphics, text = spec[0...ix], spec[ix..-1]
      addendum, shapes_and_styles = text.partition { |s| s =~ /^edge / }
      @shapes = []
      AsciiDiagram.new(graphics, addendum, Image.extract_identifiers(shapes_and_styles))
        .to_shapes
        .each { |shape| add_shape(shape) }
      @properties = {}
      @styles = { line: {}, polygon: {}, polyline: {}, path: {} }
      parse_shapes_and_styles(shapes_and_styles)
    end

    def add_shape(shape)
      @shapes << shape
      shape.image = self
    end

    def height
      @properties[:height] || @shapes.map(&:max_y).max
    end

    def margin_bottom; @properties[:"margin-bottom"] || 0; end
    def margin_left; @properties[:"margin-left"] || 0; end
    def margin_right; @properties[:"margin-right"] || 0; end
    def margin_top; @properties[:"margin-top"] || 0; end

    def parse_shapes_and_styles(shapes_and_styles)
      shapes_and_styles.each do |s|
        case s
          when /^(L\d+) (.*)/
            h_shape, h_style = JSON.parse($2, symbolize_names: true)
              .partition { |k, v| [:x1, :y1, :x2, :y2].include?(k) }
              .map(&:to_h)
            add_shape(Line.new(h_shape.merge(id: $1)))
            @styles["#" + $1] = h_style
          when /^(P\d+) (.*)/
            h_shape, h_style = JSON.parse($2, symbolize_names: true)
              .partition { |k, v| [:points].include?(k) }
              .map(&:to_h)
            add_shape(Polygon.new(h_shape.merge(id: $1))) if h_shape[:points]
            @styles["#" + $1] = h_style
          when /^(line|polyline|polygon|path) (.*)/
            klass = Object.const_get("Ritaa").const_get($1.capitalize)
            add_shape(klass.new(JSON.parse($2, symbolize_names: true)))
          when /^image (.*)/
            h = JSON.parse($1, symbolize_names: true)
            margin = h.delete(:margin)
            h.merge!(
              "margin-bottom": margin,
              "margin-left": margin,
              "margin-right": margin,
              "margin-top": margin
              ) if margin
            @properties.merge!(h)
          when /^(line|polyline|polygon|path)s (.*)/
            h = JSON.parse($2, symbolize_names: true)
            @styles[$1.to_sym].merge!(h)
          when /^([a-z]\w*) (.*)/
            h = JSON.parse($2, symbolize_names: true)
            @styles["." + $1] = h
          else raise "Unexpected entry: %s" % s
        end
      end
    end

    def to_svg
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new("1.0", "UTF-8")
      root = REXML::Element.new("svg")
      doc.add_element(root)
      root.attributes["xmlns"] = "http://www.w3.org/2000/svg"
      root.attributes["version"] = "1.1"
      root.attributes["width"] = total_width.to_s
      root.attributes["height"] = total_height.to_s
      root.attributes["viewBox"] =
        "%d %d %d %d" % [-margin_left, -margin_top, total_width, total_height]
      h = @properties.reject { |k, v| k =~ /^margin\-/ }
      unless h.empty?
        root.attributes["style"] = h.map { |k, v| "%s: %s" % [k, v] }.join("; ")
      end

      e = REXML::Element.new("style")
      root.add_element(e)
      @styles.each do |shape_type, h|
        unless h.empty?
          s = "%s { %s }" % [shape_type, h.map { |k, v| "%s: %s" % [k, v] }.join("; ")]
          e.add_text(REXML::Text.new(s))
        end
      end

      @shapes.each { |shape| root.add_element(shape.to_element) }

      res = ""; doc.write(res, 2); res
    end

    def total_height; margin_top + height + margin_bottom; end
    def total_width; margin_left + width + margin_right; end

    def width
      @properties[:height] || @shapes.map(&:max_x).max
    end

    class Point < Ritaa::Point
      def initialize(ascii_diagram_point)
        super(ascii_diagram_point.x * 5, ascii_diagram_point.y * 10)
      end
    end
  end
end
