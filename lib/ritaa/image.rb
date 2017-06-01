module Ritaa
  class Image
    RESERVED_WORDS = %w(
      line path polygon polyline
      lines paths polygons polylines
      edge image nil drop-shadow)

    def Image.extract_identifiers(shapes_and_styles)
      shapes_and_styles.map { |s| s[/^\w+/] }.compact.uniq - RESERVED_WORDS + ["nil"]
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
      @drop_shadow_styles = {} # id => Hash
      parse_shapes_and_styles(shapes_and_styles)
    end

    def add_shape(shape)
      @shapes << shape
      shape.image = self
    end

    def get_drop_shadow_class(dss_id_from_shape, id, klass, shape_type)
      dss_id =
        dss_id_from_shape ||
        (id && @styles["#" + id][:"drop-shadow"]) ||
        (klass && @styles["." + klass][:"drop-shadow"]) ||
        @styles[:polygon][:"drop-shadow"]
      if dss_id
        if dss_id == true
          dss_id = @drop_shadow_styles.keys.min
        end
        "dropshadow%d" % dss_id
      end
    end

    def get_shape(id)
      @shapes.find { |shape| shape.properties[:id] == id }
    end

    def height
      @properties[:height] || @shapes.map(&:max_y).max
    end

    def margin_bottom; @properties[:"margin-bottom"].to_i || 0; end
    def margin_left; @properties[:"margin-left"].to_i || 0; end
    def margin_right; @properties[:"margin-right"].to_i || 0; end
    def margin_top; @properties[:"margin-top"].to_i || 0; end

    def parse_shapes_and_styles(shapes_and_styles)
      shapes_and_styles.each do |s|
        case s
          when /^([LP]\d+) (.*)/
            id, other_attributes = $1, $2
            shape_class, shape_attributes =
              case id[0]
              when "L"
                [Object.const_get("Ritaa").const_get("Line"), [:x1, :y1, :x2, :y2, :z]]
              when "P"
                [Object.const_get("Ritaa").const_get("Polygon"), [:points, :z]]
              end
            h_shape, h_style = JSON.parse(other_attributes, symbolize_names: true)
              .partition { |k, v| shape_attributes.include?(k) }
              .map(&:to_h)
            shape = get_shape(id)
            if shape
              shape.properties.merge!(h_shape)
            else
              add_shape(shape_class.new(h_shape.merge(id: $1)))
            end
            @styles["#" + id] ||= {}
            @styles["#" + id].merge!(h_style)
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
          when /^drop-shadow (.*)/
            h = JSON.parse($1, symbolize_names: true)
            id = h.delete(:id)
            id = id ? id.to_i : 0
            @drop_shadow_styles[id] = h
          when /^([a-z]\w*) (.*)/
            h = JSON.parse($2, symbolize_names: true)
            @styles["." + $1] = h
          when /^((?:"[^"]*" )+)(.*)/
            nil
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
      h = @properties.reject { |k, v| k =~ /^margin\-/ || k == :"drop-shadow" }
      unless h.empty?
        root.attributes["style"] = h.map { |k, v| "%s: %s" % [k, v] }.join("; ")
      end

      elm_style = REXML::Element.new("style")
      root.add_element(elm_style)
      @styles.each do |shape_type, h|
        unless h.empty?
          s = "%s { %s }" % [shape_type,
            h.reject { |k, v| k == :"drop-shadow" }.map { |k, v| "%s: %s" % [k, v] }.join("; ")]
          elm_style.add_text(REXML::Text.new(s))
        end
      end

      @drop_shadow_styles.each do |id, h|
        elm_filter = REXML::Element.new("filter")
        root.insert_before(elm_style, elm_filter)
        elm_filter.attributes["id"] = "drop_shadow_%d" % id
        e = REXML::Element.new("feGaussianBlur")
        elm_filter.add_element(e)
        e.attributes["stdDeviation"] = h[:blur]
        e = REXML::Element.new("feOffset")
        elm_filter.add_element(e)
        e.attributes["dx"] = e.attributes["dy"] = h[:offset]
        elm_style.add_text(REXML::Text.new(
          ".dropshadow%d { fill: %s; stroke: none; filter: url(#drop_shadow_%d) }" %
          [id, h[:fill], id]))
      end

      @shapes
        .map(&:to_elements)
        .flatten
        .sort_by { |e| e.attributes["z"].to_i || 0 }
        .each { |e| e.attributes.delete("z") }
        .each { |e| root.add_element(e) }

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
