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
            //loop for every indicator with i-lengthForIndicator until i
            var tmpSum = 0.0
            for trendSmaIndex in i-trendSmaLen+1...i{
                tmpSum += candles[trendSmaIndex].close
            }
            let trendSma = tmpSum/Double(trendSmaLen)
            print("trendSma = \(trendSma)")
        }
        return []
    }
}
