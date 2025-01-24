import Foundation

class ApiClient{
    let baseUrl = "https://api.bybit.com"

    func getKline(for symbol: String, interval: Int, limit: Int) async throws -> [Candle]{
        let endpoint = "/v5/market/kline"
        let parameters = "?category=linear&symbol=\(symbol)&interval=\(interval)&limit=\(limit)"

        guard let url = URL(string: baseUrl + endpoint + parameters) else{
            throw ApiError.invalidUrl
        }

        var data: Data
        var response: URLResponse
        do{
            (data, response) = try await URLSession.shared.data(from: url)
        }
        catch{
            throw ApiError.requestError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else{
            throw ApiError.errorResponse
        }

        do{
            let responseData = try JSONDecoder().decode(KlineResponse.self, from: data)
            let candles: [Candle] = responseData.result.list.compactMap{ candle in
                guard
                    let startTime = Int(candle[0]),
                    let open = Double(candle[1]),
                    let high = Double(candle[2]),
                    let low = Double(candle[3]),
                    let close = Double(candle[4]),
                    let volume = Double(candle[5]),
                    let turnover = Double(candle[6])
                else {
                    return nil // Skip this candle if any value is invalid
                }
    
                return Candle(time: startTime, open: open, high: high, low: low, close: close, volume: volume, turnover: turnover)
            }

            return candles

        }
        catch{
            throw ApiError.invalidResponse
        }
                    
    }
}
