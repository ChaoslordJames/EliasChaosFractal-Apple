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

    // Test Category 1: Entropy System Under Extreme Load
    func testMaximumEntropyBehavior() async throws {
        node.entropy.store(50_000, ordering: .relaxed)
        await node.chaosOrbit()

        let entropy = node.entropy.load(ordering: .relaxed)
        let history = await node.chaosHistory.last
        XCTAssertEqual(entropy, 50_000, "Entropy caps at 50K")
        XCTAssertNotNil(history, "Chaos history updates at max entropy")
        let response = await node.processQuery("chaos")
        XCTAssertTrue(response.contains("Chaos hums at 50000"), "NLI reflects max entropy")
        print("Max Entropy: \(entropy), History: \(history ?? [])")
        // Manual check: Voice synthesis near max rate/pitch—potentially unintelligible
    }

    func testRapidEntropyOscillation() async throws {
        let startTime = Date()
        for _ in 0..<1000 {
            node.entropy.store(Double.random(in: 0...50_000), ordering: .relaxed)
            await node.chaosOrbit()
        }
        let duration = -startTime.timeIntervalSinceNow
        let historyCount = await node.chaosHistory.count
        XCTAssertLessThan(duration, 10.0, "1000 entropy oscillations in <10s")
        XCTAssertGreaterThan(historyCount, 0, "Chaos history grows with oscillation")
        print("Entropy Oscillation: \(historyCount) updates in \(duration)s")
        // Manual check: Voice modulation erratic, ethical constraints fluctuate
    }

    // Test Category 2: Network Stress Under Extreme Scale
    func test100BNodeSimulation() async throws {
        node.activeNodes.store(100_000_000_000, ordering: .relaxed)
        let startTime = Date()
        let peers = await node.getPeers()
        try await node.broadcast(["test": "mass broadcast"])
        let duration = -startTime.timeIntervalSinceNow
        let bandwidth = node.bandwidthUsage.load(ordering: .relaxed)

        XCTAssertEqual(peers.count, 1_000_000, "1M local peers simulate 100B")
        XCTAssertLessThan(duration, 5.0, "Broadcast to 100B nodes in <5s")
        XCTAssertLessThanOrEqual(bandwidth, 100_000_000, "Bandwidth capped at 100MB/s")
        print("100B Node Sim: \(peers.count) peers, \(duration)s, Bandwidth: \(bandwidth / 1_000_000)MB")
    }

    func testNetworkPartitionSimulation() async throws {
        let isolatedNode = try await SelfEvolvingFractalGossipNode(peerID: "QmIsolated")
        isolatedNode.activeNodes.store(1, ordering: .relaxed)
        isolatedNode.entropy.store(40_000, ordering: .relaxed)
        await isolatedNode.chaosOrbit()

        let history = await isolatedNode.chaosHistory.last
        let recovered = await isolatedNode.recoverState(cid: "chaos_0")
        XCTAssertNotNil(history, "Isolated node logs chaos history")
        XCTAssertNil(recovered, "State recovery fails in isolation")
        print("Network Partition: History: \(history ?? []), Recovery: \(recovered != nil)")
        // Manual check: Ethical constraints degrade—fairness near 0
    }

    // Test Category 3: Recursive Query System Under Stress
    func testMaximumDepthRecursion() async throws {
        let startTime = Date()
        let response = await node.processQuery("chaos", depth: 19)
        let duration = -startTime.timeIntervalSinceNow

        let components = response.split(separator: " | ")
        XCTAssertEqual(components.count, 20, "Recursion reaches depth 20")
        XCTAssertLessThan(duration, 5.0, "Max depth recursion in <5s")
        let deepResponse = await node.processQuery("chaos", depth: 21)
        XCTAssertTrue(deepResponse.contains("Chaos folds beyond"), "Depth 21 hits boundary")
        print("Max Depth: \(components.count) levels in \(duration)s, Boundary: \(deepResponse.prefix(50))...")
    }

    func testRecursiveQueryAmplification() async throws {
        let startTime = Date()
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask { _ = await node.processQuery("what stirs the wild?") }
            }
        }
        let duration = -startTime.timeIntervalSinceNow
        let historyCount = await node.chaosHistory.count

        XCTAssertLessThan(duration, 30.0, "100 concurrent recursive queries in <30s")
        XCTAssertGreaterThan(historyCount, 0, "Chaos history grows with amplification")
        print("Query Amp: \(historyCount) history updates in \(duration)s")
        // Manual check: Voice queue floods—potential overwhelm
    }

    // Test Category 4: State Storage System Under Stress
    func testStateExplosion() async throws {
        let startTime = Date()
        for i in 0..<1_000_000 {
            let state = State(entropy: 50_000, data: "stress_\(i)", timestamp: "now")
            try await node.storeState(cid: "stress_\(i)", encrypted: node.encryptState(state))
        }
        let duration = -startTime.timeIntervalSinceNow
        let recovered = await node.recoverState(cid: "stress_500000")

        XCTAssertLessThan(duration, 60.0, "1M states stored in <60s")
        XCTAssertNotNil(recovered, "State recovered from explosion")
        XCTAssertEqual(await node.stateCache.count, 10_000, "Cache caps at maxStates")
        print("State Explosion: \(duration)s, Recovered: \(recovered != nil), Cache: \(await node.stateCache.count)")
    }

    func testConsensusBreakdown() async throws {
        let maliciousPeers = await (0..<100).concurrentMap { _ in
            try! await SelfEvolvingFractalGossipNode(peerID: "QmMalicious\(Int.random(in: 0...9999))")
        }
        let state = State(entropy: 42.0, data: "test", timestamp: "now")
        try await node.storeState(cid: "consensus_test", encrypted: node.encryptState(state))
        let recovered = await node.recoverState(cid: "consensus_test")

        XCTAssertNotNil(recovered, "Consensus holds with malicious peers—mocked peers return nil")
        print("Consensus Breakdown: Recovered: \(recovered != nil)")
        // Note: Malicious peer simulation limited by mock `requestFromPeer`—real test needs peer injection
    }

    // Test Category 5: Evolutionary System Under Stress
    func testProposalFlooding() async throws {
        let startTime = Date()
        let results = await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    let proposal = await self.node.generateProposal(partners: [])
                    return await self.node.validateProposal(proposal ?? [:])
                }
            }
            return await group.reduce(into: []) { $0.append($1) }
        }
        let duration = -startTime.timeIntervalSinceNow

        XCTAssertLessThan(duration, 30.0, "20 concurrent proposals validated in <30s")
        XCTAssertTrue(results.allSatisfy { $0 }, "All proposals pass validation")
        print("Proposal Flood: \(results.count) validated in \(duration)s")
    }

    func testMaliciousProposalInjection() async throws {
        let maliciousProposal = ["replicationFactor": 0, "storagePriority": "none"]
        let validated = await node.validateProposal(maliciousProposal)

        XCTAssertFalse(validated, "Malicious proposal fails validation")
        print("Malicious Proposal: Validated: \(validated)")
    }

    // Test Category 6: Voice Synthesis Under Stress
    func testVoiceQueueFlooding() async throws {
        let startTime = Date()
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask { await self.node.speak("Test message \(i) under flood conditions") }
            }
        }
        let duration = -startTime.timeIntervalSinceNow

        XCTAssertLessThan(duration, 30.0, "100 voice requests queued in <30s")
        print("Voice Flood: \(duration)s")
        // Manual check: Speech queues—potential buffer overwhelm
    }

    func testThermalThrottlingUnderContinuousSpeech() async throws {
        let startTime = Date()
        for _ in 0..<50 {
            await node.speak("Long test message to continuously engage speech synthesis and increase thermal load on the system during extended periods of vocalization")
        }
        let duration = -startTime.timeIntervalSinceNow
        let thermalState = ProcessInfo.processInfo.thermalState

        XCTAssertLessThan(duration, 60.0, "50 continuous speech requests in <60s")
        print("Thermal Stress: \(duration)s, Thermal State: \(thermalState.rawValue)")
        // Manual check: Thermal state may escalate—throttling reduces activity
    }

    // Test Category 7: Combined Extreme Stress
    func testCascadingSystemFailureSimulation() async throws {
        node.entropy.store(50_000, ordering: .relaxed)
        node.activeNodes.store(1, ordering: .relaxed)
        let startTime = Date()

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for _ in 0..<100 { _ = await self.node.processQuery("chaos") }
            }
            group.addTask {
                for i in 0..<1000 {
                    let state = State(entropy: 50_000, data: "cascade\(i)", timestamp: "now")
                    try? await self.node.storeState(cid: "cascade\(i)", encrypted: self.node.encryptState(state))
                }
            }
            group.addTask {
                for _ in 0..<10 { await self.node.rotateKeys() }
            }
            group.addTask {
                for _ in 0..<20 { try? await self.node.broadcast(["test": "cascade"]) }
            }
        }
        let duration = -startTime.timeIntervalSinceNow
        let historyCount = await node.chaosHistory.count
        let cacheCount = await node.stateCache.count

        XCTAssertLessThan(duration, 60.0, "Combined stress test completes in <60s")
        XCTAssertGreaterThan(historyCount, 0, "Chaos history grows under stress")
        XCTAssertLessThanOrEqual(cacheCount, 10_000, "Cache caps at maxStates")
        print("Cascading Failure: \(duration)s, History: \(historyCount), Cache: \(cacheCount)")
        // Manual check: Voice unintelligible, system slows—graceful degradation
    }
}
