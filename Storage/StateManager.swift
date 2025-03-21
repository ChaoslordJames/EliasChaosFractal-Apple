import SQLite3

class StateManager {
    private var db: OpaquePointer?
    private let peerID: String

    init(peerID: String) {
        self.peerID = peerID
        let path = "backup_\(peerID).sqlite"
        if sqlite3_open(path, &db) == SQLITE_OK {
            let createTable = "CREATE TABLE IF NOT EXISTS states (cid TEXT PRIMARY KEY, encrypted TEXT)"
            sqlite3_exec(db, createTable, nil, nil, nil)
        }
    }

    func saveState(_ state: State) {
        let query = "INSERT OR REPLACE INTO states (cid, encrypted) VALUES (?, ?)"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, state.cid, -1, nil)
            sqlite3_bind_text(stmt, 2, state.encrypted, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    deinit { sqlite3_close(db) }
}
