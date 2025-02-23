import PostgresClientKit
import Foundation

class DatabaseManager{
    public var connection: Connection?

    init() {
        do {
            connection = try connectDatabase()
        } catch {
            print("DB can not be connected: \(error)")
        }
    }

    deinit {
        connection?.close()
    }

    private func connectDatabase() throws -> Connection{
        var config = ConnectionConfiguration()
        config.host = "localhost"
        config.port = 5432
        config.database = "fibonacci_trader"
        config.user = "postgres"
        config.ssl = false
        //config.credential = .cleartextPassword(password: ProcessInfo.processInfo.environment["postgres_password"] ?? "pw")
        
        print("before connection try")
        dump(config)
        let newConnection = try Connection(configuration: config)
        print("after connection try")
        return newConnection
    }

}

