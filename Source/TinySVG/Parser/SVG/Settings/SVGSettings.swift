// MIT license
// Derived from https://github.com/exyte/SVGView

import CoreGraphics
import Foundation

public struct SVGSettings {

    public static let `default` = SVGSettings()

    public let logger: SVGLogger

    public init(logger: SVGLogger = .console) {
        self.logger = logger
    }

}
