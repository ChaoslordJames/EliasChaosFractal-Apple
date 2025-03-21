import Foundation

class AdaptiveTopology {
    private var kBuckets: [KBucket] = []

    func optimizeForPeers(_ count: Int) -> [KBucket] {
        let bucketCount = max(count / 2000, 2500)
        kBuckets = (0..<bucketCount).map { KBucket(distance: $0, k: 4000) }
        return kBuckets
    }

    func getBuckets() -> [KBucket] { kBuckets }
}

struct KBucket {
    let distance: Int
    let k: Int
    var peers: [String] = []
}
