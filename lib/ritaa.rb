require_relative 'ritaa/version'

require_relative 'ritaa/point'
require_relative 'ritaa/arrow_style'
require_relative 'ritaa/image'
require_relative 'ritaa/ascii_diagram'
require_relative 'ritaa/size_manager'
require_relative 'ritaa/shape/shape'
require_relative 'ritaa/shape/line'
require_relative 'ritaa/shape/path'
require_relative 'ritaa/shape/polygon'
require_relative 'ritaa/shape/polyline'
require_relative 'ritaa/shape/rect'

require_relative 'ritaa/graph/graph'
require_relative 'ritaa/graph/directed_graph'
require_relative 'ritaa/graph/undirected_graph'

require 'json'
require 'rexml/document'

module Ritaa
  module_function
  def run(argv)
    svg = argv.delete("-svg")
    png = argv.delete("-png")
    infile = argv[0]
    infile =~ /(.*)\.ritaa$/
    svg_file = $1 + ".svg"
    png_file = $1 + ".png"
    img = Image.new(File.readlines(infile).map(&:chomp))
    File.open(svg_file, "w") { |f| f.puts img.to_svg }
    system("svgexport %s %s" % [svg_file, png_file]) if png
    File.delete(svg_file) unless svg
  end
end
