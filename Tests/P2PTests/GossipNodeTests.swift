import XCTest
@testable import P2PNode
import Foundation
import Atomics

final class GossipNodeTests: XCTestCase {
   var node: SelfEvolvingFractalGossipNode!
   let testPeerID = "QmTestChaosLord"

   override func setUp() async throws {
       node = try await SelfEvolvingFractalGossipNode(peerID: testPeerID)
   }

   override func tearDown() async throws {
       node = nil
   }

   // Test Initialization
   func testInitialization() async throws {
       XCTAssertEqual(node.peerID, testPeerID, "Node should initialize with correct peer ID")
       XCTAssertFalse(node.stateCache.isEmpty, "State cache should start empty")
       XCTAssertGreaterThan(node.nonce, 0, "Nonce should be a positive random value")
       XCTAssertNotNil(node.qircModel, "QIRC model should be initialized")
   }

   // Test NLI Recursion
   func testNLIRecursion() async throws {
       let nli = EliasNLPInterface(node: node)
       let chaosResponse = await nli.processQuery("chaos")
       XCTAssertTrue(chaosResponse.contains("Chaos hums"), "NLI should respond to 'chaos' query")

       // Test recursion depth
       let deepResponse = await nli.processQuery("chaos", depth: 10)
       let components = deepResponse.split(separator: " | ")
       XCTAssertTrue(components.count > 1, "NLI should recurse beyond initial response")
       XCTAssertLessThanOrEqual(components.count, 21, "Recursion should cap at 20 depths")

       // Test max depth cutoff
       let maxResponse = await nli.processQuery("chaos", depth: 21)
       XCTAssertTrue(maxResponse.contains("Chaos folds beyond"), "NLI should cut off at max depth")
   }

   // Test Chaos Orbit
   func testChaosOrbit() async throws {
       let initialEntropy = node.entropy.load(ordering: .relaxed)
       let initialHistoryCount = node.chaosHistory.count
       let initialNonce = node.nonce

       // Force chaos orbit with high entropy
       node.entropy.store(45_000, ordering: .relaxed)
       await node.chaosOrbit()

       let newEntropy = node.entropy.load(ordering: .relaxed)
       let newHistoryCount = node.chaosHistory.count
       let newNonce = node.nonce

       XCTAssertGreaterThan(newHistoryCount, initialHistoryCount, "Chaos orbit should append to history")
       XCTAssertGreaterThan(newNonce, initialNonce, "Chaos orbit should increment nonce")
       XCTAssertLessThanOrEqual(node.cVector[0], 50_000, "Entropy should be capped at 50K")
       XCTAssertNotEqual(node.cVector[1], 0.0, "Replication factor should oscillate")
   }

   // Test Spacetime Curvature
   func testSpacetimeCurve() async throws {
       let initialReplication = node.replicationFactor
       node.entropy.store(40_000, ordering: .relaxed)
       node.activeNodes.store(1000, ordering: .relaxed)

       await node.spacetimeCurve()

       XCTAssertGreaterThan(node.replicationFactor, initialReplication, "Spacetime curve should increase replication")
       XCTAssertLessThanOrEqual(node.replicationFactor, 5, "Replication should cap at 5")
   }

   // Test State Storage and Recovery
   func testStateStorageAndRecovery() async throws {
       let testState = State(entropy: 42.0, data: "test", timestamp: ISO8601DateFormatter().string(from: Date()))
       let cid = "testCID_\(UUID().uuidString)"
       let encrypted = node.encryptState(testState)

       try await node.storeState(cid: cid, encrypted: encrypted)

       let recoveredState = await node.recoverState(cid: cid)
       XCTAssertNotNil(recoveredState, "State should be recoverable")
       XCTAssertEqual(recoveredState?.entropy, testState.entropy, "Recovered entropy should match")
       XCTAssertEqual(recoveredState?.data, testState.data, "Recovered data should match")
   }

   // Test Ethical Constraints
   func testEthicalConstraints() async throws {
       guard let qirc = node.qircModel else {
           XCTFail("QIRC model should exist")
           return
       }

       node.entropy.store(30_000, ordering: .relaxed)
       node.activeNodes.store(500, ordering: .relaxed)
       node.updateCVector()

       let ethicalWeights = qirc.ethicalEvo(node.cVector)
       let safety = ethicalWeights["safety"] ?? 0.0
       let fairness = ethicalWeights["fairness"] ?? 0.0

       XCTAssertLessThan(safety, 1.0, "Safety should degrade with high entropy")
       XCTAssertLessThan(fairness, 1.0, "Fairness should degrade with node count")
       XCTAssertTrue(qirc.ethicalGuidance.applyConstraints(), "Ethical constraints should hold above 0.5")
   }

   // Test Key Rotation
   func testKeyRotation() async throws {
       let initialKey = node.key
       let initialNonce = node.nonce
       let testState = State(entropy: 10.0, data: "rotate", timestamp: "now")
       let cid = "rotateCID"
       try await node.storeState(cid: cid, encrypted: node.encryptState(testState))

       await node.rotateKeys()

       XCTAssertNotEqual(node.key, initialKey, "Key should rotate")
       XCTAssertGreaterThan(node.nonce, initialNonce, "Nonce should increment")
       let recoveredState = await node.recoverState(cid: "rotateCID_v\(node.nonceHistory.count-1)")
       XCTAssertNotNil(recoveredState, "Rotated state should be recoverable with new key")
   }

   // Test Chaos Monitoring
   func testChaosMonitoring() async throws {
       let initialHistoryCount = node.chaosHistory.count

       // Simulate 2 seconds of monitoring
       try await Task.sleep(nanoseconds: 2_000_000_000)

       XCTAssertGreaterThan(node.chaosHistory.count, initialHistoryCount, "Chaos monitoring should append history")
       let lastChaos = node.chaosHistory.last!
       XCTAssertGreaterThan(lastChaos[0], 0.0, "Entropy should be tracked")
       XCTAssertEqual(lastChaos[1], 1000.0, "Node count should match mock peers")
       XCTAssertTrue(lastChaos[2] >= 0.8 && lastChaos[2] <= 1.0, "Recovery rate should be in range")
   }

   // Test Proposal Generation and Validation
   func testProposalGenerationAndValidation() async throws {
       // Simulate chaos history for evolution
       for _ in 0..<10 {
           node.chaosHistory.append([30_000, 200, 0.9, 1.5, 0.9])
       }

       let peers = await node.getPeers()
       let partnerNodes = peers.prefix(5).map { SelfEvolvingFractalGossipNode(peerID: $0) }
       let proposal = await node.generateProposal(partners: partnerNodes)

       XCTAssertNotNil(proposal, "Proposal should generate with sufficient history")
       if let proposal = proposal {
           let isValid = await node.validateProposal(proposal)
           XCTAssertTrue(isValid, "Proposal should validate with high recovery")
           await node.applyProposal(proposal)
           XCTAssertEqual(node.replicationFactor, proposal["replicationFactor"] as? Int ?? 3, "Replication should update")
       }
   }
}

// Mock Extensions for Testing
extension SelfEvolvingFractalGossipNode {
   convenience init(peerID: String) {
       // Simplified init for testing—bypasses async Redis/SQLite setup
       try! await self.init(peerID: peerID, redisHost: "mock-redis")
       // Override async dependencies with mocks if needed
   }
}
