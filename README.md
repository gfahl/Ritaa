# Ritaa

## Example

test.ritaa:

    +--------------------------+

       +----------------------------------+
    +----------------------------------+

       +----------------------------------+
    eoaa
    #image {"margin-top": 5, "margin-right": 5, "margin-bottom": 5, "margin-left": 5}
    #line {"stroke": "blue", "stroke-width": 2}
    L1 {"x1": 40, "y1": 4, "x2": 30, "y2": 16, "stroke": "red"}
    line {"x1": 10, "y1": 4, "x2": 25, "y2": 16, "stroke": "green", "stroke-width": 5}
    L3 {"x1": 65, "y1": 0, "x2": 55, "y2": 16}

<!-- . -->

    ritaa test.ritaa

test.svg:

![](test.svg)

test.png:

![](test.png)

## Installation

Eventually:

    gem install ritaa

## Dependencies

### Ruby

- [Ruby home page](https://www.ruby-lang.org/en/)

### Node.js

Used by _svgexport_

- [Node.js home page](https://nodejs.org/en/)

### svgexport

For conversion from `.svg` to `.png` format.

- [svgexport home page](https://github.com/shakiba/svgexport)
