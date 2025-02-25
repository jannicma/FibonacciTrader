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

            if try checkNoteExists(connection: connection, assetName: assetName, timeframe: timeframe, note: note) { return }
            
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

    private func checkNoteExists(connection: Connection, assetName: String, timeframe: String, note: String) throws -> Bool {
        let noteCheckQuery = "SELECT COUNT(*) FROM backtest_runs WHERE asset_name = $1 AND timeframe = $2 AND algo_note = $3 ;"

        let noteCheckStatement = try connection.prepareStatement(text: noteCheckQuery)
        defer { noteCheckStatement.close() }

        let noteCheckCursor = try noteCheckStatement.execute(parameterValues: [assetName, timeframe, note])
        defer { noteCheckCursor.close() }

        if let row = noteCheckCursor.next() {
            let count = try row.get().columns[0].int()
            return count > 0
        }
        
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Count of backtest_runs with same note did not return anything"])
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
