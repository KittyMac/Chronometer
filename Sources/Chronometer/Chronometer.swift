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

struct DateFormat {
    let formatter: DateFormatter
    let verify: (String) -> Bool
    
    func date(from: String) -> Date? {
        guard verify(from) else { return nil }
        return formatter.date(from: from)
    }
    
    init(format: String, verify: @escaping (String) -> Bool) {
        formatter = DateFormatter()
        formatter.dateFormat = format
        self.verify = verify
    }
}

fileprivate var allDateFormats = [DateFormat]()
fileprivate var allDateFormatsLock = NSLock()
fileprivate func initDateFormats() {
    guard allDateFormats.count == 0 else { return }
    
    // javascript uses Sat Aug 13 2022 12:53:29 GMT-0400 (EDT)
    // https://nsdateformatter.com
    
    // second argument is a "performant sanity check the string matches the requirements of the formatter"
    let formats: [(String, (String) -> Bool)] = [
        ("E MMM d yyyy HH:mm:ss Z", { s in return s.count >= 16 }),
        ("E MMM dd yyyy HH:mm:ss Z", { s in return s.count >= 16 }),
        ("E MMM d yyyy HH:mm:ss", { s in return s.count >= 16 }),
        ("E MMM dd yyyy HH:mm:ss", { s in return s.count >= 16 }),
        ("yyyy-MM-dd HH:mm:ss Z", { s in return s.count >= 16 }),
        ("MM/dd/yyyy HH:mm:ss", { s in return s.count == 19 }),
        ("MM/dd/yyyy h:mm a", { s in return s.count > 11 }),
        ("MM/dd/yyyy h:mma", { s in return s.count > 11 }),
        ("M/d/yyyy h:mm a", { s in return s.count > 11 }),
        ("M/d/yyyy h:mma", { s in return s.count > 11 }),
        ("MMMM dd, yyyy", { s in return s.count > 11 }),
        ("MMMM d, yyyy h:mm a", { s in return s.count > 11 }),
        ("MMMM d, yyyy h:mma", { s in return s.count > 11 }),
        ("MMMM d, yyyy", { s in return s.count > 11 }),
        ("MMM dd, yyyy", { s in return s.count > 11 }),
        ("MMM d, yyyy, h:mm a", { s in return s.count > 11 }),
        ("MMM d, yyyy, h:mma", { s in return s.count > 11 }),
        ("MMM d, yyyy", { s in return s.count > 9 }),
        ("MM-dd-yy", { s in return s.count == 8 }),
        ("M-d-yy", { s in return s.count <= 8 }),
        ("MM-dd-yyyy", { s in return s.count == 10 }),
        ("M-d-yyyy", { s in return s.count <= 10 }),
        ("yyyy-MM-dd", { s in return s.count == 10 }),
        ("yyyy-M-d", { s in return s.count <= 10 }),
        ("yyyy/MM/dd", { s in return s.count == 10 }),
        ("yyyy/M/d", { s in return s.count <= 10 }),
        ("MM/dd/yyyy", { s in return s.count == 10 }),
        ("M/d/yyyy", { s in return s.count >= 8 && s.count <= 10 }),
        ("MM/dd/yy", { s in return s.count == 8 }),
        ("M/d/yy", { s in return s.count >= 6 && s.count <= 8 }),
        ("H:mm A", { s in return s.count < 16 }),
        ("HH:mm", { s in return s.count < 10 })
    ]
    
    for format in formats {
        allDateFormats.append(DateFormat(format: format.0, verify: format.1))
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
        
        var dateString = self
        if self.contains("GMT") {
            dateString = self.replacingOccurrences(of: "GMT", with: "")
            dateString = String(dateString.split(separator: "(")[0])
        }
        
        allDateFormatsLock.lock(); defer { allDateFormatsLock.unlock() }
        initDateFormats()
        for formatter in allDateFormats {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }

}
