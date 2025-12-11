// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics

extension CGFloat {

    var degreesToRadians: CGFloat {
        self * .pi / 180
    }

}

extension String {

    var cgFloatValue: CGFloat? {
        if let value = Double(self) {
            return CGFloat(value)
        }
        return .none
    }
}

extension CGAffineTransform {

    func shear(shx: CGFloat = 0, shy: CGFloat = 0) -> CGAffineTransform {
        CGAffineTransform(a: a + c * shy, b: b + d * shy,
                          c: a * shx + c, d: b * shx + d, tx: tx, ty: ty)
    }

}
