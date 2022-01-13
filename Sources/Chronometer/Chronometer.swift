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

public extension String {
    func date() -> Date? {
        let dateStringRange = NSRange(location: 0, length: self.count)

        let parseIso8601: () -> Date? = {

            var match = extendedIsoRegex.matches(in: self, options: [], range: dateStringRange).first
            if match == nil {
                match = basicIsoRegex.matches(in: self, options: [], range: dateStringRange).first
            }

            guard let match = match else { return nil }

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

        return parseIso8601()
    }

}
