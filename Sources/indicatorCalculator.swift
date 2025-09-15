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


            tmpSum = 0
            for longSmaIndex in i-longSmaLen+1...i{
                tmpSum += candles[longSmaIndex].close
            }
            let longSma = tmpSum/Double(longSmaLen)


            tmpSum = 0
            for shortSmaIndex in i-shortSmaLen+1...i{
                tmpSum += candles[shortSmaIndex].close
            }
            let shortSma = tmpSum/Double(shortSmaLen)


            // New RSI calc...
            var gainRma = 0.0
            var lossRma = 0.0

            let initStartIndex = i - (11*rsiLen) + 1
            let initEndIndex = i - (10*rsiLen)
            for initLossGainIndex in initStartIndex...initEndIndex{
                let currCandle = candles[initLossGainIndex]
                if currCandle.close > currCandle.open{
                    gainRma += currCandle.close - currCandle.open
                }
                else{
                    lossRma += currCandle.open - currCandle.close
                }
            }

            // make init to SMA
            gainRma /= Double(rsiLen)
            lossRma /= Double(rsiLen)

            //calculate RMA of rest
            for lossGainRmaIndex in initEndIndex+1...i{
                let currCandle = candles[lossGainRmaIndex]
                if currCandle.close > currCandle.open{
                    let change = currCandle.close - currCandle.open
                    gainRma = ((gainRma * Double(rsiLen - 1)) + change) / Double(rsiLen)
                    lossRma = (lossRma * Double(rsiLen - 1)) / Double(rsiLen)
                }
                else{
                    let change = currCandle.open - currCandle.close
                    gainRma = (gainRma * Double(rsiLen - 1)) / Double(rsiLen)
                    lossRma = ((lossRma * Double(rsiLen - 1)) + change) / Double(rsiLen)
                }
            }
            
            let rs = gainRma / (lossRma > 0.0 ? lossRma : 1.0)
            let rsi = lossRma == 0.0 ? 100.0 : gainRma == 0.0 ? 0.0 : 100 - (100 / (1 + rs))



            //calc ADX
            var adx = 0.0
    
            //create indicatorCandle
            let newIndicatorCandle = IndicatorCandle(time: candles[i].time, 
                                                    open: candles[i].open, 
                                                    high: candles[i].high, 
                                                    low: candles[i].low, 
                                                    close: candles[i].close, 
                                                    volume: candles[i].volume, 
                                                    turnover: candles[i].turnover, 
                                                    smaTrend: trendSma, 
                                                    smaLong: longSma, 
                                                    smaShort: shortSma, 
                                                    rsi: rsi,
                                                    adx: adx)

            indicatorCandles.append(newIndicatorCandle)

        }
        return indicatorCandles
    }
}
