# Ritaa

## Example

test.ritaa:

    +--------------------------+       +------+   +--+
                                       |          |  |
       +-------------------------------+--------+ +  +------------------+
    +----------------------------------+        |    |
                                            +---+----+
       +----------------------------------+
    +-----+-----+-----+-----+-----+-----+-----+-----+-----+
    |                 |     |           |                 |
    |                 |     |           |                 |
    +-----+     +-----+     +-----+     +-----+-----+     +
    |     |     |                 |           |     |     |
    |     |     |                 |           |     |     |
    +     +-----+-----+     +-----+     +-----+     +-----+
    |           |     |     |     |     |           |     |
    |           |     |     |     |     |           |     |
    +     +-----+     +-----+     +-----+     +-----+     +
    |     |           |     |     |           |           |
    |     |           |     |     |           |           |
    +     +     +-----+     +     +-----+-----+-----+     +     +
    |     |     |           |           |           |     |
    |     |     |           |           |           |     |
    +     +-----+     +-----+     +-----+     +-----+     +     +
    |     |           |           |     |     |           |     |
    |     |           |           |     |     |           |     +
    +     +     +-----+-----+-----+     +     +-----+-----+     |
    |     |     |                       |                 |     +
    |     |     |                       |                 |     |
    +-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+
    edge {"x1": 0, "y1": 3, "x2": 3, "y2": 5}
    edge {"x1": 35, "y1": 3, "x2": 38, "y2": 5}
    L1 {"x1": 20, "y1": 1, "x2": 15, "y2": 4, "stroke": "red"}
    line {"x1": 5, "y1": 1, "x2": 12, "y2": 4}
    L3 {"x1": 32, "y1": 0, "x2": 27, "y2": 4, "stroke": "green", "stroke-width": 5}
    image {"margin": 5, "stroke": "#444", "stroke-width": 1}
    lines {"stroke": "blue", "stroke-width": 2}
    polygons {"fill": "#ccc"}
    polylines {"fill": "none"}
    paths {"fill": "none"}

<!-- . -->

    ritaa test.ritaa -svg -png

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
