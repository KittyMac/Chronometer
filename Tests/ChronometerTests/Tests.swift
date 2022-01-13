import XCTest
import class Foundation.Bundle

import Chronometer

class ChronometerTests: TestsBase {
    
    private func compareFormat(_ format: String) -> Bool {
        let now = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        // The date string when the format is known
        let rhs = dateFormatter.string(from: now)
        
        // The date string when the format is unknown
        let lhs = dateFormatter.string(for: rhs.date())
        
        if lhs != rhs {
            XCTAssertEqual(lhs, rhs)
        }
        
        return lhs == rhs
    }
    
    
    func testISO8061() {
        XCTAssert(compareFormat("yyyy-MM-dd HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("Y-'W'ww-e HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("yyyy-D HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("yyyy-DDD HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("yyyyMMdd HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("Y'W'wwe HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("yyyyDDD HH:mm:ss.SSSZZZZZ"))
        
        XCTAssert(compareFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("Y-'W'ww-e'T'HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("yyyy-D'T'HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("yyyy-DDD'T'HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("yyyyMMdd'T'HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("Y'W'wwe'T'HH:mm:ss.SSSZZZZZ"))
        XCTAssert(compareFormat("yyyyDDD'T'HH:mm:ss.SSSZZZZZ"))
        
        XCTAssert(compareFormat("yyyy-MM-dd'T'HH:mm:ss"))
        XCTAssert(compareFormat("Y-'W'ww-e'T'HH:mm:ss"))
        XCTAssert(compareFormat("yyyy-D'T'HH:mm:ss"))
        XCTAssert(compareFormat("yyyy-DDD'T'HH:mm:ss"))
        XCTAssert(compareFormat("yyyyMMdd'T'HH:mm:ss"))
        XCTAssert(compareFormat("Y'W'wwe'T'HH:mm:ss"))
        XCTAssert(compareFormat("yyyyDDD'T'HH:mm:ss"))
        
        XCTAssert(compareFormat("yyyy-MM-dd'T'HH:mm"))
        XCTAssert(compareFormat("Y-'W'ww-e'T'HH:mm"))
        XCTAssert(compareFormat("yyyy-D'T'HH:mm"))
        XCTAssert(compareFormat("yyyy-DDD'T'HH:mm"))
        XCTAssert(compareFormat("yyyyMMdd'T'HH:mm"))
        XCTAssert(compareFormat("Y'W'wwe'T'HH:mm"))
        XCTAssert(compareFormat("yyyyDDD'T'HH:mm"))
        
        XCTAssert(compareFormat("yyyy-MM-dd"))
        XCTAssert(compareFormat("Y-'W'ww-e"))
        XCTAssert(compareFormat("yyyy-D"))
        XCTAssert(compareFormat("yyyy-DDD"))
        XCTAssert(compareFormat("yyyyMMdd"))
        XCTAssert(compareFormat("Y'W'wwe"))
        XCTAssert(compareFormat("yyyyDDD"))
        
        XCTAssert(compareFormat("Y-'W'ww"))
        XCTAssert(compareFormat("yyyy-MM"))
        XCTAssert(compareFormat("Y'W'ww"))
        XCTAssert(compareFormat("yyyyMM"))
        XCTAssert(compareFormat("yyyy"))
    }
}
