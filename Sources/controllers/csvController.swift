import Foundation

class CsvController{
    public func getCandlesFromCsv(csv fileName: String) -> [Candle]{
        var candles: [Candle] = []
        do{
            let content = try String(contentsOfFile: fileName, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

            for line in lines{
                let fields = line.components(separatedBy: ",")
                if fields.count == 6 && fields[0] != "time"{
                    let candle = Candle(
                        time: Int(fields[0])!,
                        open: Double(fields[1])!,
                        high: Double(fields[2])!,
                        low: Double(fields[3])!,
                        close: Double(fields[4])!,
                        volume: Double(fields[5])!,
                        turnover: 0.0
                    )
                    
                    candles.append(candle)
                }
            }
        }
        catch{
            print("Error reading CSV file")
        }

        return candles
    }
}
