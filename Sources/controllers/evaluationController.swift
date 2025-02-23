import Foundation

class EvaluationController{
    let possibleEntryCounts = [1, 2, 3, 4]
    let possibleClosingTypes = [
            "directSl",
            "tp1>SlProf",
            "tp1>tp2>SlProf",
            "tp1>tp2>tpCross"
    ]

    let evaluationDataService = EvaluationDataService()

    public func evaluate(trades: [Trade], name: String = "", filePath: String = ""){
        let evaluation = calculateEvaluation(for: trades)
        saveEvaluations(evaluations: evaluation, totalTrades: trades.count, name: name, file: filePath)
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


    private func saveEvaluations(evaluations: [String: Int], totalTrades: Int, name: String, file: String){
        let splittedName = name.split(separator: ",")
        let asset = splittedName[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let timeframe = splittedName[1].split(separator: ".")[0].trimmingCharacters(in: .whitespacesAndNewlines)

        let note = """
            Version 0
            GP with RSI Divergence
            Options: 
                \(possibleClosingTypes)
            """
        evaluationDataService.saveEvaluation(evaluations: evaluations, totalTrades: totalTrades, assetName: asset, timeframe: timeframe, note: note)
    }
}
