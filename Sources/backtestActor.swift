import Foundation

/*
    This Actor is the main for the backtesting. it works as its own program
    it should not change anything outside of himself. only use its own instances of classes.
*/
actor BacktestActor{

    public func startBacktest() async{
        let marketController = MarketController()
        let indicatorCalculator = IndicatorCalculator()

        let candles = await marketController.fetchKline(for: "BTCUSDT", interval: 30, limit: 500)

        guard candles.count > 0 else{
            print("error fetching data")
            return
        }

        let indicatorCandles = indicatorCalculator.convertCandleToIndicatorCandle(candles: candles)
        print("count of candles fetched: \(candles.count)")
        print("count of indicator candles: \(indicatorCandles.count)")

        let simulatedTrades = simulate(with: indicatorCandles)
        
    }


    private func simulate(with candles: [IndicatorCandle]) -> [Trade]{ 
        // 1. Get high and low for up and down trend
        // 2. Reset high and low at the right times

        var candleHigh: IndicatorCandle?
        var candleLow: IndicatorCandle?

        var lastCrossIndex = 0

        for i in 1..<candles.count{
            let currCandle = candles[i]
            let lastCandle = candles[i-1]

            let isBullTrend = currCandle.smaShort > currCandle.smaTrend && currCandle.smaLong > currCandle.smaTrend
            let isBearTrend = currCandle.smaShort < currCandle.smaTrend && currCandle.smaLong < currCandle.smaTrend

            let isCrossOver = currCandle.smaShort > currCandle.smaLong && lastCandle.smaShort < lastCandle.smaLong
            let isCrossUnder = currCandle.smaShort < currCandle.smaLong && lastCandle.smaShort > lastCandle.smaLong



            if isCrossUnder && lastCrossIndex > 0{
                if isBearTrend{
                    candleHigh = nil
                    candleLow = nil
                }
                candleHigh = getPivotCandle(candles: candles, indexFrom: lastCrossIndex, indexTo: i, findHigh: true)
            }

            if isCrossOver && lastCrossIndex > 0{
                if isBullTrend{
                    candleLow = nil
                    candleHigh = nil
                }
                candleLow = getPivotCandle(candles: candles, indexFrom: lastCrossIndex, indexTo: i, findHigh: false)
            }


            if isCrossOver || isCrossUnder{
                lastCrossIndex = i
            }


            if isBullTrend{

            }


            if isBearTrend{
            
            }


        }

        return []

    }


    private func getPivotCandle(candles: [IndicatorCandle], indexFrom: Int, indexTo: Int, findHigh: Bool) -> IndicatorCandle?{
        var newPivot: IndicatorCandle?

        for index in indexFrom...indexTo{
            let candle = candles[index]
            if findHigh{
                if newPivot == nil || candle.high > newPivot!.high{
                    newPivot = candle
                }
            }
            else{
                if newPivot == nil || candle.low < newPivot!.low{
                    newPivot = candle
                }
            }
        }

        return newPivot
    }
}



