import Foundation

// Note: This is largely taken from Moment.js from-string.js
// https://github.com/moment/moment

private let extendedIsoRegex = try! NSRegularExpression(pattern: #"^\s*((?:[+-]\d{6}|\d{4})-(?:\d\d-\d\d|W\d\d-\d|W\d\d|\d\d\d|\d\d))(?:(T| )(\d\d(?::\d\d(?::\d\d(?:[.,]\d+)?)?)?)([+-]\d\d(?::?\d\d)?|\s*Z)?)?"#, options: [])
private let basicIsoRegex = try! NSRegularExpression(pattern: #"^\s*((?:[+-]\d{6}|\d{4})(?:\d\d\d\d|W\d\d\d|W\d\d|\d\d\d|\d\d|))(?:(T| )(\d\d(?::\d\d(?::\d\d(?:[.,]\d+)?)?)?)([+-]\d\d(?::?\d\d)?|\s*Z)?)?"#, options: [])
private let tzRegex = try! NSRegularExpression(pattern: #"Z|[+-]\d\d(?::?\d\d)?"#, options: [])

private let isoDates = [
    ("yyyy-MM-dd", try! NSRegularExpression(pattern: #"\d{4}-\d\d-\d\d"#, options: [])),
    ("Y-'W'ww-e", try! NSRegularExpression(pattern: #"\d{4}-W\d\d-\d"#, options: [])),
    ("Y-'W'ww", try! NSRegularExpression(pattern: #"\d{4}-W\d\d"#, options: [])),
    ("yyyy-D", try! NSRegularExpression(pattern: #"\d{4}-\d\d?\d?"#, options: [])),
    ("yyyy-MM", try! NSRegularExpression(pattern: #"\d{4}-\d\d"#, options: [])),
    ("yyyyMMdd", try! NSRegularExpression(pattern: #"\d{8}"#, options: [])),
    ("Y'W'wwe", try! NSRegularExpression(pattern: #"\d{4}W\d{3}"#, options: [])),
    ("Y'W'ww", try! NSRegularExpression(pattern: #"\d{4}W\d{2}"#, options: [])),
    ("yyyyDDD", try! NSRegularExpression(pattern: #"\d{4}\d\d\d"#, options: [])),
    ("yyyyMM", try! NSRegularExpression(pattern: #"\d{6}"#, options: [])),
    ("yyyy", try! NSRegularExpression(pattern: #"\d{4}"#, options: []))
]

// yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ

// iso time formats and regexes
private let isoTimes = [
    ("HH:mm:ss.SSS", try! NSRegularExpression(pattern: #"\d\d:\d\d:\d\d\.\d+"#, options: [])),
    ("HH:mm:ss,SSS", try! NSRegularExpression(pattern: #"\d\d:\d\d:\d\d,\d+"#, options: [])),
    ("HH:mm:ss", try! NSRegularExpression(pattern: #"\d\d:\d\d:\d\d"#, options: [])),
    ("HH:mm", try! NSRegularExpression(pattern: #"\d\d:\d\d"#, options: [])),
    ("HHmmss.SSS", try! NSRegularExpression(pattern: #"\d\d\d\d\d\d\.\d+"#, options: [])),
    ("HHmmss,SSS", try! NSRegularExpression(pattern: #"\d\d\d\d\d\d,\d+"#, options: [])),
    ("HHmmss", try! NSRegularExpression(pattern: #"\d\d\d\d\d\d"#, options: [])),
    ("HHmm", try! NSRegularExpression(pattern: #"\d\d\d\d"#, options: [])),
    ("HH", try! NSRegularExpression(pattern: #"\d\d"#, options: []))
]

private let aspNetJsonRegex = try! NSRegularExpression(pattern: #"^\/?Date\((-?\d+)"#, options: [])

// RFC 2822 regex: For details see https://tools.ietf.org/html/rfc2822#section-3.3
private let rfc2822 = try! NSRegularExpression(pattern: #"^(?:(Mon|Tue|Wed|Thu|Fri|Sat|Sun),?\s)?(\d{1,2})\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s(\d{2,4})\s(\d\d):(\d\d)(?::(\d\d))?\s(?:(UT|GMT|[ECMP][SD]T)|([Zz])|([+-]\d{4}))$"#, options: [])

private let obsOffsets = [
    "UT": 0,
    "GMT": 0,
    "EDT": -4 * 60,
    "EST": -5 * 60,
    "CDT": -5 * 60,
    "CST": -6 * 60,
    "MDT": -6 * 60,
    "MST": -7 * 60,
    "PDT": -7 * 60,
    "PST": -8 * 60
]


fileprivate var allDateFormats = [DateFormatter]()
fileprivate func initDateFormats() {
    guard allDateFormats.count == 0 else { return }
    
    // javascript uses Sat Aug 13 2022 12:53:29 GMT-0400 (EDT)
    // https://nsdateformatter.com
        
    let formats = [
        "E MMM d yyyy HH:mm:ss Z",
        "E MMM dd yyyy HH:mm:ss Z",
        "E MMM d yyyy HH:mm:ss",
        "E MMM dd yyyy HH:mm:ss",
        "MM/dd/yyyy",
        "M/d/yyyy",
        "MM/dd/yy",
        "M/d/yy",
        "H:mm A",
        "HH:mm",
        "MM/dd/yyyy HH:mm:ss",
        "MM/dd/yyyy h:mm a",
        "MM/dd/yyyy h:mma",
        "M/d/yyyy h:mm a",
        "M/d/yyyy h:mma",
        "MMMM dd, yyyy",
        "MMMM d, yyyy h:mm a",
        "MMMM d, yyyy h:mma",
        "MMMM d, yyyy",
        "MMM dd, yyyy",
        "MMM d, yyyy, h:mm a",
        "MMM d, yyyy, h:mma",
        "MMM d, yyyy",
        "MM-dd-yy",
        "M-d-yy",
        "MM-dd-yyyy",
        "M-d-yyyy",
        // Support for Swift date description format
        "yyyy-MM-dd HH:mm:ss Z"
    ]
    
    formats.forEach { format in
        let formatter = DateFormatter()
        formatter.dateFormat = format
        allDateFormats.append(formatter)
    }
    
}



public extension String {
    func date() -> Date? {
        let dateStringRange = NSRange(location: 0, length: self.count)

        let parseIso8601: () -> Date? = {

            var fullMatch = extendedIsoRegex.matches(in: self, options: [], range: dateStringRange).first
            if fullMatch == nil {
                fullMatch = basicIsoRegex.matches(in: self, options: [], range: dateStringRange).first
            }

            guard let match = fullMatch else { return nil }

            var dateFormat = ""
            for format in isoDates {
                if format.1.firstMatch(in: self, options: [], range: dateStringRange) != nil {
                    dateFormat = format.0
                    break
                }
            }

            guard dateFormat.isEmpty == false else { return nil }

            var timeFormat = ""
            if match.numberOfRanges > 3 {
                let timeRange = match.range(at: 3)
                if timeRange.location != NSNotFound {
                    if let separatorRange = Range(match.range(at: 2), in: self) {
                        var separatorString = String(self[separatorRange])
                        if separatorString != " " {
                            separatorString = "'\(separatorString)'"
                        }
                        for format in isoTimes {
                            if format.1.firstMatch(in: self, options: [], range: timeRange) != nil {
                                timeFormat = separatorString + format.0
                                break
                            }
                        }
                    }
                }
            }

            var tzFormat = ""
            if match.numberOfRanges > 4 {
                let zoneRange = match.range(at: 4)
                if zoneRange.location != NSNotFound {
                    if tzRegex.firstMatch(in: self, options: [], range: zoneRange) != nil {
                        tzFormat = "ZZZZZ"
                    }
                }
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "\(dateFormat)\(timeFormat)\(tzFormat)"
            return dateFormatter.date(from: self)
        }
        
        if let date = parseIso8601() {
            return date
        }
        
        initDateFormats()
        
        var dateString = self
        if self.contains("GMT") {
            dateString = self.replacingOccurrences(of: "GMT", with: "")
            dateString = String(dateString.split(separator: "(")[0])
        }
        
        for formatter in allDateFormats {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        
        return nil
    }

}
