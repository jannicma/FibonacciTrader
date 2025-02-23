import Foundation
import PostgresClientKit

class EvaluationDataService{
    private let dbManager: DatabaseManager

    init() {
        dbManager = DatabaseManager()
    }

    public func saveEvaluation(evaluations: [String: Int], totalTrades: Int, assetName: String, timeframe: String, note: String){
        let query = """
            INSERT INTO backtest_runs (asset_name, timeframe, test_datetime, algo_note, total_trades)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING run_id
            """

        do{
            guard let connection = dbManager.connection else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database Connection is NIL"])
            }

            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }

            let timestamp = PostgresTimestamp(date: Date(), in: TimeZone(abbreviation: "CET")!)
            let cursor = try statement.execute(parameterValues: [assetName, timeframe, timestamp, note, totalTrades])
            defer { cursor.close() }

            if let row = cursor.next() {
                let runId = try row.get().columns[0].int()
                try saveOutcomes(runId: runId, evaluations: evaluations)
            } else {
                print("No ID returned from evaluation adding")
            }

        } catch {
            print("Ohh Ohh, saveEvaluation made an error: \(error)")
        }
    }


    private func saveOutcomes(runId: Int, evaluations: [String: Int]) throws {
        guard let connection = dbManager.connection else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database Connection is NIL"])
        }

        let outcomeQuery = """
            INSERT INTO outcomes (run_id, num_entries, closing_type, count)
            VALUES ($1, $2, $3, $4)
            """
        let outcomeStatement = try connection.prepareStatement(text: outcomeQuery)
        defer { outcomeStatement.close() }
        
        for (key, count) in evaluations {
            let parts = key.split(separator: "_")
            let numEntries = Int(parts[0])!
            let closingType = String(parts[2])

            try outcomeStatement.execute(parameterValues: [runId, numEntries, closingType, count])
        }
    }
}
