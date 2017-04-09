require 'json'
require 'rexml/document'

class Ritaa
  def Ritaa.run(argv)
    infile = argv[0]
    infile =~ /(.*)\.ritaa$/
    svg_file = $1 + ".svg"
    png_file = $1 + ".png"
    img = Image.new(File.readlines(infile))
    File.open(svg_file, "w") { |f| f.puts img.to_svg }
    system("svgexport %s %s" % [svg_file, png_file])
  end
end

class Image
  def initialize(spec)
    ix = spec.find_index { |s| s =~ /^eoaa/ }
    aa_spec, other_spec =
      if ix
        [spec[0...ix], spec[ix + 1..-1]]
      else
        [spec, []]
      end
    #
    @properties = {}
    @shapes = []
    @styles = {line: {}}
    parse_aa(aa_spec)
    parse_other(other_spec)
  end

  def height
    @properties[:height] || @shapes.map(&:max_y).max
  end

  def margin_bottom; @properties[:"margin-bottom"] || 0; end
  def margin_left; @properties[:"margin-left"] || 0; end
  def margin_right; @properties[:"margin-right"] || 0; end
  def margin_top; @properties[:"margin-top"] || 0; end

  def parse_aa(spec)
    spec.each.with_index do |s, i|
      pos = s =~ /\+\-+\+/
      if pos
        x1 = pos * 2
        x2 = x1 + ($&.size - 1) * 2
        y1 = y2 = i * 4
        @shapes << Line.new(x1: x1, y1: y1, x2: x2, y2: y2)
      end
    end
  end

  def parse_other(spec)
    spec.each do |s|
      if s =~ /^#image (.*)/
        h = JSON.parse($1, symbolize_names: true)
        @properties.merge!(h)
      elsif s =~ /^#line (.*)/
        h = JSON.parse($1, symbolize_names: true)
        @styles[:line].merge!(h)
      elsif s =~ /^line (.*)/
        h = JSON.parse($1, symbolize_names: true)
        @shapes << Line.new(h)
      elsif s =~ /^(L\d+) (.*)/
        h = JSON.parse($2, symbolize_names: true).merge(id: $1)
        @shapes << Line.new(h)
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

    e = REXML::Element.new("style")
    @styles.each do |shape_type, h|
      unless h.empty?
        s = "%s { %s }" % [shape_type, h.map { |k, v| "%s: %s" % [k, v] }.join("; ")]
        e.add_text REXML::Text.new(s)
      end
    end
    if e.text
      root.add_element(e)
    end

    @shapes.each do |shape|
      root.add_element(shape.to_element)
    end

    res = ""
    doc.write(res, 2)
    res
  end

  def total_height; margin_top + height + margin_bottom; end
  def total_width; margin_left + width + margin_right; end

  def width
    @properties[:height] || @shapes.map(&:max_x).max
  end
end

class Line
  def initialize(h = {})
    @properties = h
  end

  def max_x; [@properties[:x1], @properties[:x2]].max; end
  def max_y; [@properties[:y1], @properties[:y2]].max; end

  def to_element
    e = REXML::Element.new("line")
    styles = []
    @properties.each do |k, v|
      case k
      when :stroke, :"stroke-width"
        styles << "%s: %s" % [k, v]
      else
        e.attributes[k.to_s] = @properties[k].to_s
      end
    end
    unless styles.empty?
      e.attributes["style"] = styles.join("; ")
    end
    e
  end
end
