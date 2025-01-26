struct IndicatorCandle: Decodable{
    let time: Int
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    let turnover: Double
    let smaTrend: Double
    let smaLong: Double
    let smaShort: Double
    let rsi: Double
}
