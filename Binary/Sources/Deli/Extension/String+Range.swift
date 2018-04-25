//
//  String+Range.swift
//  Deli
//

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (i: Int) -> String {
        return String(self[i])
    }
    subscript (r: CountableRange<Int>) -> String {
        return String(self[r.lowerBound...(r.upperBound - 1)])
    }
    subscript (r: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start...end])
    }
    subscript (r: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        return String(self[start...])
    }
}
