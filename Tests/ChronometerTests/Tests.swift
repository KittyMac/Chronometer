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
    
    func testPerformance() {
        // average: 2.054
        let sample = "09/13/2023 01:08:10"
        measure {
            for _ in 0..<10000 {
                XCTAssertNotNil(sample.date())
            }
        }
    }
    
    func testJavascript() {
        let sample = "Sat Aug 13 2022 12:53:29"
        let date = sample.date()
        XCTAssertNotNil(date)
        print(date!)
        
        let sample2 = "Sat Aug 13 2022 11:53:29 -0900"
        let date2 = sample2.date()
        XCTAssertNotNil(date2)
        print(date2!)
        
        let sample3 = "Sat Aug 13 2022 13:12:43 GMT-0900 (EDT)"
        let date3 = sample3.date()
        XCTAssertNotNil(date3)
        print(date3!)
    }
    
    func testMisc() {
        XCTAssert(compareFormat("MM/dd/yyyy"))
        XCTAssert(compareFormat("M/d/yyyy"))
        XCTAssert(compareFormat("MM/dd/yy"))
        XCTAssert(compareFormat("M/d/yy"))
        XCTAssert(compareFormat("H:mm A"))
        XCTAssert(compareFormat("HH:mm"))
        XCTAssert(compareFormat("MM/dd/yyyy HH:mm:ss"))
        XCTAssert(compareFormat("MM/dd/yyyy h:mm a"))
        XCTAssert(compareFormat("M/d/yyyy h:mm a"))
        XCTAssert(compareFormat("MMMM dd, yyyy"))
        XCTAssert(compareFormat("MMMM d, yyyy h:mm a"))
        XCTAssert(compareFormat("MMMM d, yyyy h:mm a"))
        XCTAssert(compareFormat("MMMM d, yyyy"))
        XCTAssert(compareFormat("MMM dd, yyyy"))
        XCTAssert(compareFormat("MMM d, yyyy, h:mm a"))
        XCTAssert(compareFormat("MMM d, yyyy, h:mm a"))
        XCTAssert(compareFormat("MMM d, yyyy"))
        XCTAssert(compareFormat("MM-dd-yy"))
        XCTAssert(compareFormat("M-d-yy"))
        XCTAssert(compareFormat("MM-dd-yyyy"))
        XCTAssert(compareFormat("M-d-yyyy"))
        XCTAssert(compareFormat("MM/dd/yyyy"))
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
        
        XCTAssert(compareFormat("yyyy-MM-dd HH:mm:ss"))
        XCTAssert(compareFormat("Y-'W'ww-e HH:mm:ss"))
        XCTAssert(compareFormat("yyyy-D HH:mm:ss"))
        XCTAssert(compareFormat("yyyy-DDD HH:mm:ss"))
        XCTAssert(compareFormat("yyyyMMdd HH:mm:ss"))
        XCTAssert(compareFormat("Y'W'wwe HH:mm:ss"))
        XCTAssert(compareFormat("yyyyDDD HH:mm:ss"))
        
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
         
        //XCTAssert(compareFormat("yyyy-MM"))
        
        XCTAssert(compareFormat("Y'W'ww"))
        XCTAssert(compareFormat("yyyyMM"))
        XCTAssert(compareFormat("yyyy"))
    }
    
    func testAppleDateDescription() {
        let date = "1/1/2021".date()!
        
        XCTAssertNotNil(date.description.date())
        XCTAssertEqual(date, date.description.date())
    }
}
