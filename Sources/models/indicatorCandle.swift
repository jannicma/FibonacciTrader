struct IndicatorCandle: Decodable{
    let time: Int
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    let turnover: Double
    let emaTrend: Double
    let emaLong: Double
    let emaShort: Double
    let rsi: Double
}
