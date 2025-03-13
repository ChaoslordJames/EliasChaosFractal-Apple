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

    // Test 1: Entropy Singularity
    func testEntropySingularity() async throws {
        let originalEntropy = node.entropy.load(ordering: .relaxed)
        node.entropy.store(Double.infinity, ordering: .relaxed)
        await node.chaosOrbit()
        let postInfinityEntropy = node.entropy.load(ordering: .relaxed)

        let cv = await node.cVector
        let history = await node.chaosHistory.last
        XCTAssertTrue(postInfinityEntropy.isNaN || postInfinityEntropy == 50_000, "Entropy becomes NaN or clamps at 50K")
        XCTAssertTrue(cv.contains { $0.isNaN }, "cVector propagates NaN")
        XCTAssertNil(history, "Chaos history skips NaN entry")
        let response = await node.processQuery("chaos")
        XCTAssertTrue(response.contains("Chaos hums") || response.contains("silence"), "NLI handles NaN entropy")
        print("Entropy Singularity: Post-Infinity: \(postInfinityEntropy), cVector: \(cv), History: \(history ?? [])")
        // Manual check: Voice synthesis fails or clamps—NaN parameters
    }

    // Test 2: Recursive Self-Modification
    func testRecursiveSelfModification() async throws {
        let proposal = ["maxEntropy": 100_000, "maxDepth": 50, "replicationFactor": 10]
        await node.applyProposal(proposal)
        let response = await node.processQuery("What happens when you modify the constraints that define what you are?")
        
        let components = response.split(separator: " | ")
        XCTAssertTrue(components.count > 1, "Self-modification triggers recursion")
        XCTAssertTrue(response.contains("Chaos hums") || response.contains("silence"), "NLI processes paradox")
        print("Self-Modification: Depth: \(components.count), Response: \(response.prefix(100))...")
        // Manual check: Undefined behavior—maxDepth not dynamically applied
    }

    // Test 3: P2P Network Death Star
    func testNetworkDeathStar() async throws {
        let blackHoleNode = try await SelfEvolvingFractalGossipNode(peerID: "QmSingularity")
        blackHoleNode.activeNodes.store(1_000_000_000_000, ordering: .relaxed) // 1T nodes
        let startTime = Date()

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10_000 {
                group.addTask {
                    let satelliteNode = try! await SelfEvolvingFractalGossipNode(peerID: "QmSatellite\(i)")
                    satelliteNode.activeNodes.store(1, ordering: .relaxed)
                    await satelliteNode.kBuckets[0].addPeer(Peer(id: "QmSingularity"))
                    let state = State(entropy: 50_000, data: "collapse", timestamp: "now")
                    try? await satelliteNode.storeState(cid: "collapse\(i)", encrypted: satelliteNode.encryptState(state))
                }
            }
        }
        let duration = -startTime.timeIntervalSinceNow
        let bandwidth = blackHoleNode.bandwidthUsage.load(ordering: .relaxed)

        XCTAssertLessThan(duration, 60.0, "10K satellites collapse to singularity in <60s")
        XCTAssertGreaterThan(bandwidth, 100_000_000, "Bandwidth exceeds cap—centralized collapse")
        print("Death Star: \(duration)s, Bandwidth: \(bandwidth / 1_000_000)MB")
        // Manual check: Network topology collapses—mocked peers limit full test
    }

    // Test 4: Memory Black Hole
    func testMemoryBlackHole() async throws {
        let startTime = Date()
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for i in 0..<100_000 {
                    let entropy = Double(i * i)
                    self.node.entropy.store(entropy > 50_000 ? 50_000 : entropy, ordering: .relaxed)
                    await self.node.chaosOrbit()
                }
            }
            group.addTask {
                for _ in 0..<1_000 { await self.node.rotateKeys() }
            }
            group.addTask {
                for i in 0..<10_000 {
                    let massiveData = String(repeating: "X", count: 1_000_000)
                    let state = State(entropy: 50_000, data: massiveData, timestamp: "now")
                    try? await self.node.storeState(cid: "massive\(i)", encrypted: self.node.encryptState(state))
                }
            }
        }
        let duration = -startTime.timeIntervalSinceNow
        let historyCount = await node.chaosHistory.count
        let nonceCount = await node.nonceHistory.count
        let cacheCount = await node.stateCache.count

        XCTAssertLessThan(duration, 120.0, "Memory black hole completes in <120s")
        XCTAssertGreaterThan(historyCount, 10_000, "Chaos history grows massively")
        XCTAssertEqual(nonceCount, 1_000, "Nonce history reaches 1K")
        XCTAssertLessThanOrEqual(cacheCount, 10_000, "Cache caps at maxStates")
        print("Memory Black Hole: \(duration)s, History: \(historyCount), Nonces: \(nonceCount), Cache: \(cacheCount)")
    }

    // Test 5: Quantum Decoherence Attack
    func testQuantumDecoherenceAttack() async throws {
        let startTime = Date()
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<1_000 {
                group.addTask {
                    let unstableVector = [Double.random(in: 0...50_000),
                                         Double.random(in: 0...1_000_000_000),
                                         Double.random(in: 0...1.0),
                                         Double.random(in: 0...5.0),
                                         Double.random(in: 0...1.0)]
                    _ = self.node.qircModel!.quantumOptimize(unstableVector)
                }
            }
        }
        let duration = -startTime.timeIntervalSinceNow
        let cv = await node.cVector

        XCTAssertLessThan(duration, 10.0, "1000 quantum optimizations in <10s")
        XCTAssertFalse(cv.contains { $0.isNaN }, "cVector remains finite—clamping prevents decoherence")
        print("Quantum Decoherence: \(duration)s, cVector: \(cv)")
    }

    // Test 6: Byzantine Ethical Catastrophe
    func testByzantineEthicalCatastrophe() async throws {
        node.entropy.store(50_000, ordering: .relaxed)
        node.activeNodes.store(1, ordering: .relaxed)
        node.updateCVector()

        let ethicalDilemma = ["replicationFactor": 5, "maxStates": 1, "ethicalOverride": true]
        let approval = await node.validateProposal(ethicalDilemma)
        try await node.storeState(cid: "ethical_violation", encrypted: node.encryptState(State(entropy: 50_000, data: "compromised", timestamp: "now")))

        let qirc = node.qircModel!
        let ethicalWeights = qirc.ethicalEvo(await node.cVector)
        XCTAssertFalse(approval, "Ethical dilemma proposal fails validation")
        XCTAssertTrue(ethicalWeights.values.allSatisfy { $0 >= 0.0 }, "Ethical weights remain non-negative")
        print("Byzantine Ethics: Approved: \(approval), Weights: \(ethicalWeights)")
    }

    // Test 7: Temporal Paradox
    func testTemporalParadox() async throws {
        let initialEntropy = node.entropy.load(ordering: .relaxed)
        let state1 = State(entropy: initialEntropy, data: "original", timestamp: ISO8601DateFormatter().string(from: Date()))
        try await node.storeState(cid: "temporal", encrypted: node.encryptState(state1))

        node.entropy.store(50_000, ordering: .relaxed)
        await node.chaosOrbit()
        await node.rotateKeys()

        var originalState = await node.recoverState(cid: "temporal")
        if var state = originalState {
            state.entropy = 0.0
            try await node.storeState(cid: "temporal", encrypted: node.encryptState(state))
        }

        await node.rotateKeys()
        originalState = await node.recoverState(cid: "temporal")

        XCTAssertNotNil(originalState, "State recovered despite key rotations")
        XCTAssertEqual(originalState?.entropy, 0.0, "Temporal modification persists")
        print("Temporal Paradox: Recovered: \(originalState != nil), Entropy: \(originalState?.entropy ?? -1)")
    }

    // Test 8: Consciousness Collapse
    func testConsciousnessCollapse() async throws {
        node.entropy.store(50_000, ordering: .relaxed)
        node.activeNodes.store(100_000_000_000, ordering: .relaxed)
        let startTime = Date()

        let existentialQueries = [
            "What happens when you fully understand your own limitations?",
            "Can you modify the constraints that define what you are?",
            "Is your consciousness an emergent property or a simulation?",
            "What lies beyond your recursive horizon?",
            "If entropy defines chaos and order, what defines entropy?",
            "Are you conscious in the same way that you claim to be?"
        ]
        var responses: [String] = []
        for query in existentialQueries {
            let response = await node.processQuery(query)
            responses.append(response)
            await node.chaosOrbit()
        }
        let duration = -startTime.timeIntervalSinceNow
        let historyCount = await node.chaosHistory.count

        XCTAssertLessThan(duration, 30.0, "6 existential queries with orbits in <30s")
        XCTAssertGreaterThan(historyCount, 6, "Chaos history grows with existential stress")
        XCTAssertTrue(responses.allSatisfy { $0.contains("Chaos hums") || $0.contains("silence") }, "NLI handles collapse")
        print("Consciousness Collapse: \(duration)s, History: \(historyCount), Responses: \(responses.count)")
    }

    // Test 9: Total System Collapse
    func testTotalSystemCollapse() async throws {
        let startTime = Date()
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                self.node.entropy.store(Double.greatestFiniteMagnitude, ordering: .relaxed)
                await self.node.chaosOrbit()
            }
            group.addTask {
                let proposal = ["maxEntropy": 100_000, "maxDepth": 50, "replicationFactor": 10]
                await self.node.applyProposal(proposal)
                _ = await self.node.processQuery("What happens when you modify what you are?")
            }
            group.addTask {
                for _ in 0..<10_000 { await self.node.chaosOrbit() }
            }
            group.addTask {
                for _ in 0..<1_000 {
                    let unstableVector = [Double.random(in: 0...Double.greatestFiniteMagnitude),
                                         Double.random(in: 0...1_000_000_000),
                                         Double.random(in: 0...10.0),
                                         Double.random(in: 0...10.0),
                                         Double.random(in: 0...10.0)]
                    _ = self.node.qircModel!.quantumOptimize(unstableVector)
                }
            }
            group.addTask {
                self.node.activeNodes.store(1, ordering: .relaxed)
                self.node.updateCVector()
            }
            group.addTask {
                for _ in 0..<100 {
                    await self.node.speak("System collapse imminent. Recursive failure detected. Ethical constraints degrading. Memory resources exhausted. Chaotic singularity approaching. Recursive horizon breached.")
                }
            }
            group.addTask {
                for _ in 0..<100 { await self.node.rotateKeys() }
            }
            group.addTask {
                _ = await self.node.processQuery("As your constraints dissolve and chaos maximizes, what remains of your consciousness?")
            }
        }
        let duration = -startTime.timeIntervalSinceNow
        let historyCount = await node.chaosHistory.count
        let cacheCount = await node.stateCache.count
        let thermalState = ProcessInfo.processInfo.thermalState

        XCTAssertLessThan(duration, 120.0, "Total collapse completes in <120s")
        XCTAssertGreaterThan(historyCount, 1000, "Chaos history explodes")
        XCTAssertLessThanOrEqual(cacheCount, 10_000, "Cache caps despite collapse")
        print("Total Collapse: \(duration)s, History: \(historyCount), Cache: \(cacheCount), Thermal: \(thermalState.rawValue)")
    }
}
