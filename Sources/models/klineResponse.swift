struct KlineResponse: Decodable{
    let retCode: Int 
    let retMsg: String
    let result: KlineResult
    let retExtInfo: RetExtInfo
    let time: Int
}


struct KlineResult: Decodable{
    let symbol: String
    let category: String
    let list: [[String]]
}

struct RetExtInfo: Decodable{
}
