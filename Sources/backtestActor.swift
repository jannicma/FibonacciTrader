import Foundation

/*
    This Actor is the main for the backtesting. it works as its own program
    it should not change anything outside of himself. only use its own instances of classes.
*/
actor BacktestActor{

    func startBacktest() async{
        let marketController = MarketController()
        let indicatorCalculator = IndicatorCalculator()

        let candles = await marketController.fetchKline(for: "BTCUSDT", interval: 30, limit: 500)

        guard candles.count > 0 else{
            print("error fetching data")
            return
        }

        print("here")
        let abc = indicatorCalculator.convertCandleToIndicatorCandle(candles: candles)
    }


}
