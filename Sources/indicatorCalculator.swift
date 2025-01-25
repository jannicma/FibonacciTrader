import Foundation

class IndicatorCalculator{
    let trendSmaLen = 200
    let longSmaLen = 20
    let shortSmaLen = 5
    let rsiLen = 14

    func convertCandleToIndicatorCandle(candles: [Candle]) -> [IndicatorCandle]{
        guard candles.count > trendSmaLen else{
            return []
        }
        
        var indicatorCandles: [IndicatorCandle] = []
        for i in trendSmaLen-1...candles.count-1{
            print(candles[i].close)
            
            var date = Date(timeIntervalSince1970: (Double(candles[i].time) / 1000.0))
            print("date = \(date)")

            //loop for every indicator with i-lengthForIndicator until i
            var tmpSum = 0.0
            for trendSmaIndex in i-trendSmaLen+1...i{
                tmpSum += candles[trendSmaIndex].close
            }
            let trendSma = tmpSum/Double(trendSmaLen)
            print("trendSma = \(trendSma)")


            tmpSum = 0
            for longSmaIndex in i-longSmaLen+1...i{
                tmpSum += candles[longSmaIndex].close
            }
            let longSma = tmpSum/Double(longSmaLen)
            print("longSma = \(longSma)")


            tmpSum = 0
            for shortSmaIndex in i-shortSmaLen+1...i{
                tmpSum += candles[shortSmaIndex].close
            }
            let shortSma = tmpSum/Double(shortSmaLen)
            print("shortSma = \(shortSma)")

            // Use RMA calculation
            // When indicatorCandles.count == 0, then no smooting. 
            // If there is a indicatorCandle, take last with indicatorCandles.last and use the RMA calcuation to smooth
            // You can do this! I believe in you!
            var sumGain = 0.0, sumLoss = 0.0
            var countGain = 0, countLoss = 0
            for rsiIndex in i-rsiLen+1...i{
                let currCandle = candles[rsiIndex]
                if currCandle.close > currCandle.open{
                    sumGain += currCandle.close - currCandle.open
                    countGain += 1
                }
                else{
                    sumLoss += currCandle.open - currCandle.close
                    countLoss += 1
                }
            }

            let avgGain = sumGain / Double(countGain > 0 ? countGain : 1)
            let avgLoss = sumLoss / Double(countLoss > 0 ? countGain : 1)

            let rs = avgGain / avgLoss
            let rsi = 100 - ( 100 / (1+rs) )
            print("rsi = \(rsi)")
            print()
        }
        return []
    }
}
