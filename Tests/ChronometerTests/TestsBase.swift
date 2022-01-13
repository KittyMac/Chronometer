import XCTest
import class Foundation.Bundle

import Chronometer

public class TestsBase: XCTestCase {
    let now = Date()
    
    func nowLike(_ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: now).date()
    }
}
