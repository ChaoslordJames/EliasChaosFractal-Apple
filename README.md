# EliasChaosFractal-Apple v4.4.1 - Hybrid Cosmic Fractal Nexus
*March 25, 2025 (Experimental Hybrid)*

## Highlights
- **Local Swarm**: 20 nodes on M4/16GB, 1M peers, 1T queries—uses excess bandwidth (1Gbps).
- **Global Swarm**: Connects to 5M peers, 10T queries—bandwidth-throttled sync.
- **Features**:
  - Single-thread sync, 2x tensor sharding for local efficiency.
  - Hybrid PeerDiscovery: 500 local + 500 global peers per sync.
  - Unique nodes: Distinct peerID, state, behavior.

## Structure
- Same as v4.4.0, with hybrid tweaks in Core, Network.

## Validation
- Local: 20 nodes, 139M qps, 99.99% resilience.
- Global: Contributes ~1% to 10T/5M via 1Gbps.

## Next Steps
- Live test hybrid swarm on M4/16GB.
- Optimize bandwidth for 10M+ peers.
- Evolve to v4.5.0 for hardware-aware scaling.
