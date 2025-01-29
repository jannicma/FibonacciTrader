struct Trade: Decodable{
    let entry1: Double              // entry at .618
    let entry2: Double              // entry 1/3 between .618 and .75
    let entry3: Double              // entry 2/3 between .618 and .75
    let entry4: Double              // entry at .75

    var isEntry1: Bool              // is it hit?
    var isEntry2: Bool
    var isEntry3: Bool
    var isEntry4: Bool

    let stopLoss: Double            // SL level (lower low)
    var isStopLoss: Bool            // is SL hit?

    let stopLossProfit: Double      // SL in profit after tp1 hit
    var isStopLossProfit: Bool       // SL in profit hit

    let takeProfit1: Double         // TP 1 level (.382 probably)
    let takeProfit2: Double         // TP 2 level (higher high)
    var takeProfitCross: Double?    // where sma's cross again

    var isTakeProfit1: Bool         // is TP hit?
    var isTakeProfit2: Bool
    
}
