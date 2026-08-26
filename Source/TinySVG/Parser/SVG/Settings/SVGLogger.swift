// MIT license
// Derived from https://github.com/exyte/SVGView

import Foundation

public final class SVGLogger {

    public static let console = SVGLogger()

    public func log(message: String) {
        print(message)
    }

    public func log(error: Error) {
        log(message: error.localizedDescription)
    }

}
