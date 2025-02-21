import Foundation

class EvaluationController{
    let possibleEntryCounts = [1, 2, 3, 4]
    let possibleClosingTypes = [
            "directSl",
            "tp1>SlProf",
            "tp1>tp2>SlProf",
            "tp1>tp2>tpCross"
    ]

    public func evaluate(trades: [Trade], name: String = "", filePath: String = ""){
        let evaluation = calculateEvaluation(for: trades)
        printEvaluation(evaluations: evaluation, totalTrades: trades.count, name: name, file: filePath)
    }

    private func calculateEvaluation(for trades: [Trade]) -> [String: Int]{
        var outcomeCounts: [String: Int] = [:]
        for num in possibleEntryCounts{
            for closeType in possibleClosingTypes{
                outcomeCounts["\(num)_entries_\(closeType)"] = 0
            }
        }

        for trade in trades{
            var entryCount = 0

            if trade.isEntry1 { entryCount += 1 }
            if trade.isEntry2 { entryCount += 1 }
            if trade.isEntry3 { entryCount += 1 }
            if trade.isEntry4 { entryCount += 1 }

            

            if entryCount == 0{
                print("Warning: Trade with no entries at timestamp \(trade.timestamp ?? 0)")
                continue
            }


            let closingType = getClosingType(trade: trade)
            let key = "\(entryCount)_entries_\(closingType)"
            outcomeCounts[key, default: 0] += 1
        }

        return outcomeCounts
    }


    private func getClosingType(trade: Trade) -> String{
        if trade.isStopLoss {
            return "directSl"
        } else if trade.isStopLossProfit {
            return trade.isTakeProfit2 ? "tp1>tp2>SlProf" : "tp1>SlProf"
        } else {
            return "tp1>tp2>tpCross"
        }
    }


    private func printEvaluation(evaluations: [String: Int], totalTrades: Int, name: String, file: String){
        var output = "=== Trade Outcomes for \(name) ===\n"
        output += "Total Trades: \(totalTrades)\n"
    
        for num in possibleEntryCounts.reversed() {
            output += "\nFor \(num) entries hit:\n"
            for closingType in possibleClosingTypes {
                let key = "\(num)_entries_\(closingType)"
                let count = evaluations[key] ?? 0
                let percentage = totalTrades > 0 ? Double(count) / Double(totalTrades) * 100 : 0.0
                output += "- \(closingType): \(count) (\(String(format: "%.2f", percentage))%)\n"
            }
        }
        output += "=================================\n\n"
    
        // Convert output string to data
        guard let data = output.data(using: .utf8) else {
            print("error on encoding data")
            return
        }
    
        // Check if file exists and append or create
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: file) {
            // File exists, append to it
            do {
                let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: file))
                fileHandle.seekToEndOfFile() // Move to the end of the file
                fileHandle.write(data)       // Append the data
                fileHandle.closeFile()
            } catch {
                print("error writing file!")    
            }
        } 

    }
}
