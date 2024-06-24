import Foundation

class CarDataParser {

    var targetMake: String
    var targetModel: String
    var targetYear: Int
    var carDetails: [String: String]?
    
    init(targetMake: String, targetModel: String, targetYear: Int) {
        self.targetMake = targetMake
        self.targetModel = targetModel
        self.targetYear = targetYear
    }
    
    func fetchAndParseCSV() {
        guard let csvFileURL = Bundle.main.url(forResource: "car_data2", withExtension: "csv") else {
            fatalError("CSV file not found in bundle")
        }
        
        readCSV(from: csvFileURL)
    }
    
    private func readCSV(from fileURL: URL) {
        do {
            let data = try String(contentsOf: fileURL, encoding: .utf8)
            parseCSV(data: data)
        } catch {
            print("Error reading CSV from \(fileURL): \(error.localizedDescription)")
        }
    }
    
    private func parseCSV(data: String) {
        let rows = data.split(separator: "\n")
        guard let header = rows.first?.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) else {
            print("Invalid CSV format: No header row found")
            return
        }
        
        let dataRows = rows.dropFirst()
        var rowCount = 0
        var foundExactMatch = false
        var closestMatch: [String: String]?
        var closestYearDifference = Int.max
        
        for row in dataRows {
            let columns = row.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            var details = [String: String]()
            
            for (index, column) in columns.enumerated() {
                if index < header.count {
                    details[header[index]] = column
                }
            }
            
            if let make = details["Make"], let model = details["Model"], let yearString = details["Year"], let year = Int(yearString),
               make == targetMake {
                if model == targetModel && year == targetYear {
                    carDetails = details
                    foundExactMatch = true
                    break
                } else if model.contains(targetModel) || targetModel.contains(model) {
                    let yearDifference = abs(year - targetYear)
                    if yearDifference < closestYearDifference {
                        closestYearDifference = yearDifference
                        closestMatch = details
                    }
                }
            }
            
            rowCount += 1
        }
        
        if !foundExactMatch, let closestMatch = closestMatch {
            carDetails = closestMatch
        }
    }
}
