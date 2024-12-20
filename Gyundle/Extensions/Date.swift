import Foundation

extension Date {
    func toYearMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy_M"
        
        return dateFormatter.string(from: self)
    }
    
    func toDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "d"
        
        return dateFormatter.string(from: self)
    }
}
