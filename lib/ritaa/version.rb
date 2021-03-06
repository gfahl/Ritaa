module Ritaa
  VERSION = '0.4.0'

  ########## 0.4.0
  #
  # Lines can have arrows
  # Lines can have id/class identifiers
  # Row and column sizes in the ascii diagram can be variying
  # The image can have a background colour
  # Recognize text in the ascii diagram and show in the image
  # New shape types: Rect, Text
  # Margin sizes can now be specified using 1-4 values a la CSS

  ########## 0.3.0
  #
  # Drop-shadows can be added to polygons
  # Faces which should not generate a polygon can be excluded
  # Shapes can be given a z-value which will determine their relative position among shapes

  ########## 0.2.0
  #
  # Recognize id/class identifiers inside polygons
  #
  # An identifier becomes an svg *id* attribute if it starts with an upper-case letter
  # An identifier becomes an svg *class* attribute if it starts with a lower-case letter
  #
  # Polygons, polylines, and paths can now be specified in the JSON section

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
