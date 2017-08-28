module Ritaa
  class Image
    RESERVED_WORDS = %w(
      line path polygon polyline
      lines paths polygons polylines
      edge image nil drop-shadow)

    def Image.extract_identifiers(shapes_and_styles)
      shapes_and_styles.map { |s| s[/^\w+/] }.compact.uniq - RESERVED_WORDS + ["nil"]
    end

    def Image.expand_import(shapes_and_styles)
      shapes_and_styles.map do |s|
        if s =~ /^import (.*)/
          a = File.readlines("%s.ritaa-style" % $1).map(&:chomp)
          Image.expand_import(a)
        else [s]
        end
      end.flatten
    end

    def Image.expand_import_0(shapes_and_styles)
    end

    def initialize(spec, style)
      ix = spec.find_index { |s| s =~ /^\w/ }
      graphics, text = spec[0...ix], spec[ix..-1]
      addendum, shapes_and_styles = text.partition { |s| s =~ /^edge / }
      shapes_and_styles.unshift("import %s" % style)
      shapes_and_styles = Image.expand_import(shapes_and_styles)
      # while shapes_and_styles.find { |s| s =~ /^import / }
      #   shapes_and_styles = Image.expand_import(shapes_and_styles)
      # end
      @shapes = []
      AsciiDiagram.new(graphics, addendum, Image.extract_identifiers(shapes_and_styles))
        .to_shapes
        .each { |shape| add_shape(shape) }
      @properties = {}
      @styles = { line: {}, polygon: {}, polyline: {}, path: {}, rect: {}, text: {} }
      @drop_shadow_styles = {} # id => Hash
      @arrow_styles = {} # id => ArrowStyle
      @size_manager = SizeManager.new(10, 5)
      parse_shapes_and_styles(shapes_and_styles)
    end

    def add_shape(shape)
      @shapes << shape
      shape.image = self
    end

    def get_arrow_styles(arrow_start_id_from_shape, arrow_end_id_from_shape, id, klass)
      a = [
        arrow_start_id_from_shape,
        (id && @styles["#" + id][:"arrow-start"]),
        (klass && @styles["." + klass][:"arrow-start"]),
        @styles[:line][:"arrow-start"]
        ].compact
      start_id = a.first
      if start_id == true
        start_id = a.find { |_id| _id != true } || @arrow_styles.keys.min
      end

      a = [
        arrow_end_id_from_shape,
        (id && @styles["#" + id][:"arrow-end"]),
        (klass && @styles["." + klass][:"arrow-end"]),
        @styles[:line][:"arrow-end"]
        ].compact
      end_id = a.first
      if end_id == true
        end_id = a.find { |_id| _id != true } || @arrow_styles.keys.min
      end

      [start_id, end_id].map { |_id| @arrow_styles[_id] }
    end

    def get_drop_shadow_class(dss_id_from_shape, id, klass)
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
      text_styles = []
      shapes_and_styles.each do |s|
        case s
          when /size (.*)/ then @size_manager.add_sizes(JSON.parse($1))
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
          when /^(line|polyline|polygon|path|rect|text) (.*)/
            klass = Object.const_get("Ritaa").const_get($1.capitalize)
            add_shape(klass.new(JSON.parse($2, symbolize_names: true)))
          when /^image (.*)/
            h = JSON.parse($1, symbolize_names: true)
            margin = h.delete(:margin)
            if margin
              margins = margin.split
              margins =
                case margins.size
                when 1 then margins * 4
                when 2 then margins * 2
                when 3 then margins << margins[1]
                else margins[0..3]
                end
              h.merge!(
                "margin-top": margins[0],
                "margin-right": margins[1],
                "margin-bottom": margins[2],
                "margin-left": margins[3])
            end
            @properties.merge!(h)
          when /^(line|polyline|polygon|path|rect|text)s (.*)/
            h = JSON.parse($2, symbolize_names: true)
            @styles[$1.to_sym].merge!(h)
          when /^drop-shadow (.*)/
            h = JSON.parse($1, symbolize_names: true)
            id = h.delete(:id)
            id = id ? id.to_i : 0
            @drop_shadow_styles[id] = h
          when /^arrow (.*)/
            h = JSON.parse($1, symbolize_names: true)
            arrow_style = ArrowStyle.new(h)
            @arrow_styles[arrow_style.id] = arrow_style
          when /^([a-z]\w*) (.*)/
            h = JSON.parse($2, symbolize_names: true)
            @styles["." + $1] = h
          when /^((?:(?:"[^"]*"|'[^']*'|\/[^\/]*\/) +)+)(.*)/
            text_styles << [$1, JSON.parse($2, symbolize_names: true)]
          else raise "Unexpected entry: %s" % s
        end
      end
      text_styles.each do |match_specs, h|
        match_specs.scan(/(?:"([^"]*)"|'([^']*)'|\/([^\/]*)\/)/) do |a|
          @shapes.grep(Text) do |shape|
            if a[0] && shape.text == a[0] || 
                a[1] && shape.text == a[1] ||
                a[2] && shape.text =~ Regexp.new(a[2])
              shape.properties.merge!(h)
            end
          end
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
      h = @properties.reject { |k, v| k =~ /^margin\-/ || k == :background }
      unless h.empty?
        root.attributes["style"] = h.map { |k, v| "%s: %s" % [k, v] }.join("; ")
      end

      elm_style = REXML::Element.new("style")
      root.add_element(elm_style)
      @styles.each do |shape_type, h|
        _h = h.reject { |k, v| k == :"drop-shadow" || k =~ /^arrow\-/ }
        unless _h.empty?
          s = "%s { %s }" % [shape_type, _h.map { |k, v| "%s: %s" % [k, v] }.join("; ")]
          elm_style.add_text(REXML::Text.new(s))
        end
      end

      @arrow_styles.values.map(&:to_elements).flatten.map do |elm_marker|
        root.insert_before(elm_style, elm_marker)
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

      f = REXML::Formatters::Pretty.new
      elements = @shapes
        .map(&:to_elements)
        .flatten
        .sort_by { |e| s = ""; f.write(e, s); [e.attributes["z"].to_i || 0, s] }
      if @properties[:background]
        e = REXML::Element.new("rect")
        e.attributes["x"] = -margin_left
        e.attributes["y"] = -margin_top
        e.attributes["width"] = total_width
        e.attributes["height"] = total_height
        e.attributes["style"] = "fill: %s" % @properties[:background]
        elements.unshift(e)
      end
      elements.each do |e|
        e.attributes.delete("z")
        root.add_element(e)
      end

      res = ""; doc.write(res, 2); res
    end

    def convert_point_a2i(p); @size_manager.convert_point_a2i(p); end
    def convert_x_a2i(p); @size_manager.convert_x_a2i(p); end
    def convert_y_a2i(p); @size_manager.convert_y_a2i(p); end

    def total_height; margin_top + height + margin_bottom; end
    def total_width; margin_left + width + margin_right; end

    def width
      @properties[:width] || @shapes.map(&:max_x).max
    end

    class Point < Ritaa::Point; end
  end
end
