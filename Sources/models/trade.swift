struct Trade: Decodable{
    let entry1: Double              // entry at .618
    let entry2: Double              // entry 1/3 between .618 and .75
    let entry3: Double              // entry 2/3 between .618 and .75
    let entry4: Double              // entry at .75

    let isEntry1: Bool              // is it hit?
    let isEntry2: Bool
    let isEntry3: Bool
    let isEntry4: Bool

    let stopLoss: Double            // SL level (lower low)
    let isStopLoss: Bool            // is SL hit?

    let stopLossProfit: Double      // SL in profit after tp1 hit
    let isStopLossProft: Bool       // SL in profit hit

    let takeProfit1: Double         // TP 1 level (.382 probably)
    let takeProfit2: Double         // TP 2 level (higher high)
    let takeProfitCross: Double?    // where sma's cross again

    let isTakeProfit1: Bool         // is TP hit?
    let isTakeProfit2: Bool
    
}
