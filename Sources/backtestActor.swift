import Foundation

/*
    This Actor is the main for the backtesting. it works as its own program
    it should not change anything outside of himself. only use its own instances of classes.
*/
actor BacktestActor{

    public func startBacktest() async{
        let marketController = MarketController()
        let indicatorCalculator = IndicatorCalculator()
        let csvController = CsvController()

        let useApi = false
        var candles: [Candle] = []
        if useApi{
            candles = await marketController.fetchKline(for: "BTCUSDT", interval: 30, limit: 1000)
        }
        else{
            candles = csvController.getCandlesFromCsv(csv: "/Users/jannicmarcon/Downloads/testCandles.csv")
        }

        print(candles[0].time)
        print(candles[1].time)
        print(candles[2].time)

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
        var candleHigh: IndicatorCandle?
        var candleLow: IndicatorCandle?

        var lastCrossIndex = 0

        var activeTrade: Trade?
        var finishedTrades: [Trade] = []

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


            
            if let low = candleLow, let high = candleHigh, activeTrade == nil{
                let candleZero = isBullTrend ? high.high : low.low
                let candleOne = isBullTrend ? low.low : high.high
                let compareRsi = isBullTrend ? low.rsi : high.rsi

                let fibs = getFibonacci(zero: candleZero, one: candleOne)

                activeTrade = Trade(timestamp: nil,
                                    entry1: fibs[0.618]!, entry2: fibs[0.674]!, entry3: fibs[0.73]!, entry4: fibs[0.786]!,
                                    isEntry1: false, isEntry2: false, isEntry3: false, isEntry4: false,
                                    stopLoss: fibs[1]!, isStopLoss: false,
                                    stopLossProfit: fibs[0.58]!, isStopLossProfit: false,
                                    takeProfit1: fibs[0.382]!, takeProfit2: fibs[0]!, takeProfitCross: nil,
                                    isTakeProfit1: false, isTakeProfit2: false, 
                                    compareRsi: compareRsi)
                candleHigh = nil
                candleLow = nil
            }


            
            if let trade = activeTrade{
                let isLongTrade = trade.entry1 > trade.stopLoss
                let swingExtreme = isLongTrade ? currCandle.low : currCandle.high
                let swingProfitExtreme = isLongTrade ? currCandle.high : currCandle.low
                let didDiv = isLongTrade ? trade.compareRsi > currCandle.rsi : trade.compareRsi < currCandle.rsi



                let entry1Diff = trade.entry1 - swingExtreme
                let entry1Open = trade.entry1 - currCandle.open
                if (entry1Diff > 0) == isLongTrade && (entry1Open < 0) == isLongTrade && didDiv{
                    activeTrade!.isEntry1 = true
                }

                let entry2Diff = trade.entry2 - swingExtreme
                let entry2Open = trade.entry2 - currCandle.open
                if (entry2Diff > 0) == isLongTrade && (entry2Open < 0) == isLongTrade && didDiv{
                    activeTrade!.isEntry2 = true
                }

                let entry3Diff = trade.entry3 - swingExtreme
                let entry3Open = trade.entry3 - currCandle.open
                if (entry3Diff > 0) == isLongTrade && (entry3Open < 0) == isLongTrade && didDiv{
                    activeTrade!.isEntry3 = true
                }

                let entry4Diff = trade.entry4 - swingExtreme
                let entry4Open = trade.entry4 - currCandle.open
                if (entry4Diff > 0) == isLongTrade && (entry4Open < 0) == isLongTrade && didDiv{
                    activeTrade!.isEntry4 = true
                }


                let hasEntry = (activeTrade!.isEntry1 || activeTrade!.isEntry2 || activeTrade!.isEntry3 || activeTrade!.isEntry4)

                if hasEntry && activeTrade!.timestamp == nil{
                    activeTrade!.timestamp = currCandle.time
                }

                if !hasEntry{
                    let isOverSl = isLongTrade ? currCandle.low <=  trade.stopLoss : currCandle.high >= trade.stopLoss
                    let isOverTp2 = isLongTrade ? currCandle.high >= trade.takeProfit2 : currCandle.low <= trade.takeProfit2
                    if isOverSl || isOverTp2{
                        activeTrade = nil
                    }                   
                    continue
                }


                let slDiff = trade.stopLoss - swingExtreme
                let slOpen = trade.stopLoss - currCandle.open
                if (slDiff > 0) == isLongTrade && (slOpen < 0) == isLongTrade{
                    activeTrade!.isStopLoss = true
                    finishedTrades.append(activeTrade!)
                    activeTrade = nil
                    continue
                }

                let tp1Diff = trade.takeProfit1 - swingProfitExtreme
                let tp1Open = trade.takeProfit1 - currCandle.open
                if (tp1Diff < 0) == isLongTrade && (tp1Open > 0) == isLongTrade{
                    activeTrade!.isTakeProfit1 = true
                }

                let tp2Diff = trade.takeProfit2 - swingProfitExtreme
                let tp2Open = trade.takeProfit2 - currCandle.open
                if (tp2Diff < 0) == isLongTrade && (tp2Open > 0) == isLongTrade{
                    activeTrade!.isTakeProfit2 = true
                }

                
                let slProfDiff = trade.stopLossProfit - swingExtreme
                let slProfitOpen = trade.stopLossProfit - currCandle.open
                if (slProfDiff > 0) == isLongTrade && (slProfitOpen < 0) == isLongTrade && activeTrade!.isTakeProfit1{
                    activeTrade!.isStopLossProfit = true
                    finishedTrades.append(activeTrade!)
                    activeTrade = nil
                    continue
                }
                
                let isCorrectCross = isLongTrade ? isCrossUnder : isCrossOver
                let isInBigProfits = isLongTrade ? currCandle.close > trade.takeProfit2 : currCandle.close < trade.takeProfit2
                if isCorrectCross && isInBigProfits{
                    activeTrade!.takeProfitCross = currCandle.close
                    finishedTrades.append(activeTrade!)
                    activeTrade = nil
                    continue
                }


            }

        }
        
        print("Finished Trades count: \(finishedTrades.count)")
        dump(finishedTrades)
        return finishedTrades

    }



    private func getFibonacci(zero: Double, one: Double) -> [Double: Double]{
        var fibSequence = [0: zero,
                            0.114: 0.0,
                            0.236: 0.0,
                            0.382: 0.0,
                            0.5: 0.0,
                            0.58: 0.0,
                            0.618: 0.0,
                            0.674: 0.0,
                            0.73: 0.0,
                            0.786: 0.0,
                            0.886: 0.0,
                            1: one]

        let difference = Double(abs(zero - one))

        for key in fibSequence.keys{
            let diffFactor = key * difference
            fibSequence[key] = zero>one ? ((zero - diffFactor) * 100).rounded() / 100 : ((zero + diffFactor) * 100).rounded() / 100
        }

        return fibSequence
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



