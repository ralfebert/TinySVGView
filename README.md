# SVGView 

Stripped-down version of [exyte/SVGView](https://github.com/exyte/SVGView)

Changes:
- Using structs instead of classes for the document model
- CGContext renderer (for my limited feature set) instead of using SwiftUI shapes. I started this out of curiosity, I wanted to try the „render async“ feature of the SwiftUI Canvas. It didn’t make a big difference, but I kept it anyway. Not sure if one approach is better than the other, I should play around with the use case of making parts animated or interactive first - the SwiftUI shapes might be more useful here, and might be good enough for other use cases as well.
- Removed many features that were not needed my project - not sure if there is a value of a smaller "vector path data format only" fork
