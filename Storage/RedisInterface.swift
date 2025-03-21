import Redis

class RedisInterface {
    private var connection: RedisConnection?

    init(host: String, port: Int) {
        Task {
            do {
                self.connection = try await RedisConnection.connect(to: .init(hostname: host, port: port))
            } catch {
                print("Redis connection failed: \(error)")
            }
        }
    }

    func cacheState(_ state: State) async {
        guard let conn = connection else { return }
        do {
            try await conn.set(state.cid, to: state.encrypted)
        } catch {
            print("Redis cache failed: \(error)")
        }
    }
}
