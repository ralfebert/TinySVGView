# TinySVG

A SVG parser, document model and SwiftUI Canvas view for a minimal subset of SVG.

The package has two products: `TinySVG` (parser and document model only) and `TinySVGView` (the SwiftUI view, re-exports `TinySVG`).

```swift
import TinySVGView

SVGView(contentsOf: Bundle.main.url(forResource: "drawing", withExtension: "svg")!)
```

The parsed document is a plain value tree you can inspect, modify and write back:

```swift
var svg = SVGParser.parse(contentsOf: url) as! SVGViewport
svg.contents.append(SVGRect(x: 0, y: 0, width: 10, height: 10))
try svg.xmlString()   // -> <svg xmlns="http://www.w3.org/2000/svg" …
SVGView(svg: svg)
```



## Supported feature set

| Element | Attributes |
| --- | --- |
| *every element* | `id`, `opacity`, `transform` (`translate`, `scale`, `rotate`, `skewX`, `skewY`, `matrix`) |
| *shapes and text* | `fill` and `stroke` (named CSS colors, `#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa`, `none`), `stroke-width`, `stroke-linecap`, `stroke-linejoin`, `stroke-miterlimit`, `stroke-dasharray`, `stroke-dashoffset` |
| `<svg>` | `width`, `height`, `preserveAspectRatio` |
| `<g>` | – |
| `<path>` | `d` (`M L H V C S Q T A Z`, absolute and relative), `fill-rule` |
| `<rect>` | `x`, `y`, `width`, `height`, `rx`, `ry` |
| `<circle>` | `cx`, `cy`, `r` |
| `<ellipse>` | `cx`, `cy`, `rx`, `ry` |
| `<line>` | `x1`, `y1`, `x2`, `y2` |
| `<polyline>`, `<polygon>` | `points`, `fill-rule` |
| `<text>` | `x`, `y`, `font-family`, `font-size`, `font-weight`, `font-style`, `text-anchor` |


- **Struct-based document model**: easy to build and manipulate in code.

- **Rendered into a single SwiftUI `Canvas`** via `CGContext`, can render asynchronously.

- **Reads and writes SVG**, using [XMLCoder](https://github.com/CoreOffice/XMLCoder) — the model types are `Codable`.

- **~2.500 lines of code**, easy to read and extend.

  

Not supported:

* Everything else, most notably: `viewBox`, `<tspan>`, `<use>`/`<defs>`, `<image>`, gradients, clip paths, masks, filters, CSS (`style` attributes and stylesheets), animation.
* SwiftUI shape-based rendering (could be brought back from the exyte/SVGView project)



## Notes

This is a fork from [exyte/SVGView](https://github.com/exyte/SVGView).



## Development

```
just test-macos   # swift test on macOS
just test-ios     # xcodebuild test on the iOS simulator
just format

# re-record snapshot references with:
SNAPSHOT_TESTING_RECORD=all just test-macos
```

