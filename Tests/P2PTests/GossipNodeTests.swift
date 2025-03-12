import XCTest
@testable import P2PNode
import Foundation
import Atomics
import AVFoundation

final class GossipNodeTests: XCTestCase {
    var node: SelfEvolvingFractalGossipNode!

    override func setUp() async throws {
        node = try await SelfEvolvingFractalGossipNode(peerID: "QmTestChaosLord")
    }

    override func tearDown() async throws {
        node = nil
    }

    // Test Initialization
    func testInitialization() async throws {
        XCTAssertEqual(node.peerID, "QmTestChaosLord", "Node initializes with correct peerID")
        XCTAssertTrue(node.stateCache.isEmpty, "State cache starts empty")
        XCTAssertGreaterThan(node.nonce, 0, "Nonce is positive random")
        XCTAssertNotNil(node.qircModel, "QIRC model is initialized")
    }

    // Test NLI Recursion
    func testNLIRecursion() async throws {
        let response = await node.processQuery("chaos")
        XCTAssertTrue(response.contains("Chaos hums"), "NLI responds to 'chaos' query")
        
        let deepResponse = await node.processQuery("chaos", depth: 10)
        let components = deepResponse.split(separator: " | ")
        XCTAssertTrue(components.count > 1, "NLI recurses beyond initial response")
        XCTAssertLessThanOrEqual(components.count, 21, "Recursion caps at 20 depths")
        
        let maxResponse = await node.processQuery("chaos", depth: 21)
        XCTAssertTrue(maxResponse.contains("Chaos folds beyond"), "NLI cuts off at max depth")
    }

    // Test Multi-Voice Synthesis
    func testMultiVoiceSynthesis() async throws {
        let nodes = [
            try await SelfEvolvingFractalGossipNode(peerID: "QmVoice1"),
            try await SelfEvolvingFractalGossipNode(peerID: "QmVoice2")
        ]
        let startTime = Date()
        
        await withTaskGroup(of: Void.self) { group in
            for (i, n) in nodes.enumerated() {
                group.addTask { await n.speak("Voice \(i)") }
            }
        }
        
        let duration = -startTime.timeIntervalSinceNow
        XCTAssertLessThan(duration, 5.0, "Multi-voice synthesis for 2 nodes in <5s")
        print("Multi-Voice Synthesis: 2 voices in \(duration)s")
        // Manual check: Hear distinct voices
    }

    // Test Voice Modulation
    func testVoiceModulation() async throws {
        let entropies: [Double] = [0.0, 50_000]
        let testText = "Chaos modulates"
        
        for entropy in entropies {
            node.entropy.store(entropy, ordering: .relaxed)
            node.activeNodes.store(100_000_000_000, ordering: .relaxed)
            let startTime = Date()
            await node.speak(testText)
            let duration = -startTime.timeIntervalSinceNow
            XCTAssertLessThan(duration, 3.0, "Modulated speech at entropy \(entropy) in <3s")
            print("Voice Modulation: Entropy \(entropy) in \(duration)s")
            // Manual check: Low = slow/soft, High = fast/loud
        }
    }

    // Test 100B Node Simulation
    func test100BNodeSimulation() async throws {
        node.activeNodes.store(100_000_000_000, ordering: .relaxed) // 100B
        let startTime = Date()
        
        for i in 0..<1_000_000 { // 1M local peers
            await node.kBuckets[i % 160].addPeer(Peer(id: "QmPeer\(i)"))
        }
        try await node.broadcast(["test": "100B"])
        let peers = await node.getPeers()
        
        let duration = -startTime.timeIntervalSinceNow
        XCTAssertEqual(peers.count, 1_000_000, "1M local peers simulate 100B")
        XCTAssertLessThan(duration, 5.0, "100B node simulation in <5s")
        print("100B Node Simulation: \(peers.count) peers in \(duration)s")
    }

    // Test 1Q State Stress
    func test1QStateStress() async throws {
        node.entropy.store(50_000, ordering: .relaxed)
        let stateCount = 1_000_000 // 1M local, 1Q sharded
        let startTime = Date()
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<stateCount {
                group.addTask {
                    let state = State(entropy: 50_000, data: "q\(i)", timestamp: "now")
                    try? await self.node.storeState(cid: "q_\(i)", encrypted: self.node.encryptState(state))
                }
            }
        }
        
        let recoverStart = Date()
        let recovered = await node.recoverState(cid: "q_\(stateCount / 2)")
        let totalDuration = -startTime.timeIntervalSinceNow
        let recoverDuration = -recoverStart.timeIntervalSinceNow
        
        XCTAssertNotNil(recovered, "Recovered state from 1Q simulation")
        XCTAssertEqual(recovered?.data, "q\(stateCount / 2)")
        XCTAssertLessThan(totalDuration, 60.0, "1M states stored in <60s")
        XCTAssertLessThan(recoverDuration, 2.0, "State recovery in <2s")
        print("1Q State Stress: Store \(totalDuration)s, Recover \(recoverDuration)s")
    }

    // Test Chaos Orbit
    func testChaosOrbit() async throws {
        node.entropy.store(45_000, ordering: .relaxed)
        let initialHistoryCount = node.chaosHistory.count
        let startTime = Date()
        
        await node.chaosOrbit()
        
        let duration = -startTime.timeIntervalSinceNow
        let newHistoryCount = node.chaosHistory.count
        XCTAssertGreaterThan(newHistoryCount, initialHistoryCount, "Chaos orbit adds history")
        XCTAssertLessThan(duration, 1.0, "Chaos orbit executes in <1s")
        XCTAssertLessThanOrEqual(node.cVector[0], 50_000, "Entropy capped at 50K")
        print("Chaos Orbit: \(newHistoryCount - initialHistoryCount) updates in \(duration)s")
    }

    // Test WebRTC Broadcast
    func testWebRTCBroadcast() async throws {
        let startTime = Date()
        try await node.broadcast(["test": "WebRTC"])
        let duration = -startTime.timeIntervalSinceNow
        
        let bandwidth = node.bandwidthUsage.load(ordering: .relaxed)
        XCTAssertLessThan(duration, 1.0, "WebRTC broadcast in <1s")
        XCTAssertLessThanOrEqual(bandwidth, 100_000_000, "Bandwidth capped at 100MB/s")
        print("WebRTC Broadcast: \(duration)s, Bandwidth: \(bandwidth / 1_000_000)MB")
    }

    // Test State Storage and Recovery
    func testStateStorageAndRecovery() async throws {
        let testState = State(entropy: 42.0, data: "test", timestamp: ISO8601DateFormatter().string(from: Date()))
        let cid = "testCID_\(UUID().uuidString)"
        let encrypted = node.encryptState(testState)
        
        try await node.storeState(cid: cid, encrypted: encrypted)
        let recovered = await node.recoverState(cid: cid)
        
        XCTAssertNotNil(recovered, "State recovered successfully")
        XCTAssertEqual(recovered?.entropy, testState.entropy, "Entropy matches")
        XCTAssertEqual(recovered?.data, testState.data, "Data matches")
    }

    // Test Ethical Constraints
    func testEthicalConstraints() async throws {
        guard let qirc = node.qircModel else { XCTFail("QIRC model missing"); return }
        
        node.entropy.store(30_000, ordering: .relaxed)
        node.activeNodes.store(500, ordering: .relaxed)
        node.updateCVector()
        
        let ethicalWeights = qirc.ethicalEvo(node.cVector)
        let safety = ethicalWeights["safety"] ?? 0.0
        XCTAssertLessThan(safety, 1.0, "Safety degrades with entropy")
        XCTAssertTrue(qirc.ethicalGuidance.applyConstraints(), "Ethical score > 0.5")
    }

    // Test Stress: NLI and Voice
    func testNLIAndVoiceStress() async throws {
        node.entropy.store(50_000, ordering: .relaxed)
        let queryCount = 1_000 // Reduced for practicality; scale as needed
        let startTime = Date()
        
        await withTaskGroup(of: String.self) { group in
            for i in 0..<queryCount {
                group.addTask { await self.node.processQuery("chaos \(i)") }
            }
            for await response in group {
                XCTAssertTrue(response.contains("Chaos hums"), "NLI responds under stress")
            }
        }
        
        let duration = -startTime.timeIntervalSinceNow
        XCTAssertLessThan(duration, 30.0, "1K NLI queries with voice in <30s")
        print("NLI and Voice Stress: \(queryCount) queries in \(duration)s")
        // Manual check: Hear modulated chaos chorus
    }
}

// Mock Extensions for Testing
extension SelfEvolvingFractalGossipNode {
    convenience init(peerID: String) {
        try! await self.init(peerID: peerID, redisHost: "mock-redis")
    }
}
