module Ritaa
  VERSION = '0.1.0'

  ########## 0.1.0
  #
  # Recognize lines and faces in ascii diagram
  #
  # Command-line
  #   which formats to generate is specified by including (or not) -svg and -png flags
  # Ascii diagram
  #   lines are converted to svg line, polyline, or path shapes
  #   faces are converted to svg polygon shapes
  # JSON section
  #   starts with the first line that begins with a word character
  #   all coordinates now refer to Ascii diagram units
  #     margin and stroke-width still refer to svg units
  #   edge entries
  #     complement the Ascii diagram and can contribute to lines and faces
  #   image entry
  #     all non-ritaa-specific attributes become attributes to the svg element
  #     new attribute 'margin': specifies all four margin sizes with one number
  #   default style attributes are now specified by adding a plural 's' to the shape name
  #     example: lines {"stroke": "blue", "stroke-width": 2}

  ########## 0.0.0
  #
  # Proof-of-concept
  #
  # Command-line utility that reads a .ritaa file and converts it to .svg and .png
  # Ascii diagram can contain horizontal lines (max one per row)
  # JSON section can specify:
  #   line svg shapes with
  #     attributes: all
  #     styles: stroke and stroke-width
  #   default svg styles (all) for line
  #   margin for image
end
