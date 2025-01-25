import Foundation

class MarketController{
    private let api = ApiClient()

    func fetchKline(for symbol: String = "BTCUSDT", interval: Int = 30, limit: Int = 200) async -> [Candle]{
        do{
            let candles = try await api.getKline(for: symbol, interval: interval, limit: limit)
            return candles.reversed()
        }
        catch{
            print(error)
            return []
        }
    }
}

