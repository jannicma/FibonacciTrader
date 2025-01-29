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


    }


    private func simulate(with candles: [IndicatorCandle]) -> [Trade]{ 
        //Data for trade logic
        var candleZero: IndicatorCandle?
        var candleOne: IndicatorCandle?
        
        //Data for fibonacci detection
        var lastCrossIndex: Int = 0


        var openTrades: [Trade] = []
        var closedTrades: [Trade] = []

        for i in 1...candles.count-1{
            let candle = candles[i]
            let prevCandle = candles[i-1]

            let isBullTrend = candle.smaShort > candle.smaTrend && candle.smaLong > candle.smaTrend
            let isBearTrend = candle.smaShort < candle.smaTrend && candle.smaLong < candle.smaTrend
            let didCrossOver = candle.smaShort > candle.smaLong && prevCandle.smaShort < prevCandle.smaLong
            let didCrossUnder = candle.smaShort < candle.smaLong && prevCandle.smaShort > prevCandle.smaLong

            //Only bull case for now!! TODO: Modify for bear
            if didCrossOver{
                //find low between prevCross and now
                if lastCrossIndex > 0{
                    var low: Double = 999_999_999_999
                    for lowFinderIndex in lastCrossIndex...i{
                        if candles[lowFinderIndex].low < low{
                            candleZero = candles[lowFinderIndex]
                            low = candleZero!.low
                        }
                    }
                }

                lastCrossIndex = i
            }
            
            if didCrossUnder{
                if lastCrossIndex > 0{
                    var high: Double = 0
                    for highFinderIndex in lastCrossIndex...i{
                        if candles[highFinderIndex].high > high{
                            candleOne = candles[highFinderIndex]
                            high = candleOne!.high
                        }
                    }
                }

                lastCrossIndex = i
            }

            if let candle0 = candleZero, let candle1 = candleOne{
                // calculate fibonacci .618 and .75
                let diff = candle1.high - candle0.low
                let gpDiff = diff / 100 * 61.8
                let kbDiff = diff / 100 * 75
                let slProfitDiff = diff / 100 * 58
                let tpOneDiff = diff / 100 * 38.2 // TODO: Test with .236
                
                let gp = ((candle1.high - gpDiff) * 10).rounded() / 10
                let kb = ((candle1.high - kbDiff) * 10).rounded() / 10
                let slProfit = ((candle1.high - slProfitDiff) * 10).rounded() / 10
                let tp1 = ((candle1.high - tpOneDiff) * 10).rounded() / 10

                let limitDiff = (gp - kb) / 3

                let limit2 = ((gp - limitDiff) * 10).rounded() / 10
                let limit3 = ((kb + limitDiff) * 10).rounded() / 10

                assert(limit2 - limit3 == limitDiff)

                var newTrade = Trade(entry1: gp,
                                    entry2: limit2,
                                    entry3: limit3,
                                    entry4: kb,
                                    isEntry1: false, 
                                    isEntry2: false, 
                                    isEntry3: false, 
                                    isEntry4: false,
                                    stopLoss: candle0.low,
                                    isStopLoss: false,
                                    stopLossProfit: slProfit,
                                    isStopLossProfit: false,
                                    takeProfit1: tp1,
                                    takeProfit2: candle1.high,
                                    takeProfitCross: nil,
                                    isTakeProfit1: false, 
                                    isTakeProfit2: false)

                openTrades.append(newTrade)

                

                candleZero = nil
                candleOne = nil
            }
            

            if openTrades.count > 0{
                let price = candle.close
                for tradeIndex in 0..<openTrades.count{
                    if openTrades[tradeIndex].entry1 > price{
                        openTrades[tradeIndex].isEntry1 = true
                    }

                    if openTrades[tradeIndex].entry2 > price{
                        openTrades[tradeIndex].isEntry2 = true
                    }

                    if openTrades[tradeIndex].entry3 > price{
                        openTrades[tradeIndex].isEntry3 = true
                    }

                    if openTrades[tradeIndex].entry4 > price{
                        openTrades[tradeIndex].isEntry4 = true
                    }

                    if openTrades[tradeIndex].stopLoss > price{
                        openTrades[tradeIndex].isStopLoss = true
                        closedTrades.append(openTrades[tradeIndex])
                        openTrades.remove(at: tradeIndex)
                    }

                    if openTrades[tradeIndex].isEntry1 && openTrades[tradeIndex].stopLossProfit > price{
                        openTrades[tradeIndex].isStopLossProfit = true
                        closedTrades.append(openTrades[tradeIndex])
                        openTrades.remove(at: tradeIndex)
                    }

                    if openTrades[tradeIndex].takeProfit1 < price{
                        openTrades[tradeIndex].isTakeProfit1 = true
                    }

                    if openTrades[tradeIndex].takeProfit2 < price{
                        openTrades[tradeIndex].isTakeProfit2 = true
                    }
                    
                    if didCrossUnder{
                        openTrades[tradeIndex].takeProfitCross = price
                        closedTrades.append(openTrades[tradeIndex])
                        openTrades.remove(at: tradeIndex)
                    }

                }
            }

        }
        
        print("open trades: \(openTrades.count)")
        print("closed trades: \(closedTrades.count)")
        return closedTrades
    }

}




/*

possible simulation logic
    - create a trade model as soon as fibonacci numbers are clear
        - properties: entry1, entry2, entry3, entry4, sl, slProfit, tp1, tp2, tpSmaCross, isEntry1Hit, isEntry2Hit, is..., isSlHit, isTp??Hit
        - update the model accordingly when price moves
        - if no entry got hit before invalidation, delete it
        - if position is finished, add to an array


---------

logic:

if bullTrend
    if crossover
        define low
        save low candle



*/
