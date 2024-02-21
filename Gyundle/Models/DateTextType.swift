import Foundation

enum DateTextType: Int, CaseIterable {
    case year = 0
    case month
    case day
    
    var label: String {
        switch self {
        case .year:
            return "년"
        case .month:
            return "월"
        case .day:
            return "일"
        }
    }
    
    var placeholder: String {
        switch self {
        case .year:
            return "0000"
        case .month:
            return "00"
        case .day:
            return "00"
        }
    }
    
    var maxLength: Int {
        switch self {
        case .year:
            return 4
        case .month:
            return 2
        case .day:
            return 2
        }
    }
    
    var dateRange: ClosedRange<Int> {
        switch self {
        case .year:
            return (1900...2100)
        case .month:
            return (1...12)
        case .day:
            return (1...31)
        }
    }
}

extension DateTextType {
    mutating func moveToNext() {
        if let nextValue = DateTextType(rawValue: rawValue + 1) {
            self = nextValue
            print(self)
        }
    }
    
    
}
