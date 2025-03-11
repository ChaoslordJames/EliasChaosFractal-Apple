#!/bin/bash
# Deploy EliasChaosFractal-Apple v3.1
swift build
swift run P2PNode --peer-id QmChaosLordJames & # Swarm
swift run P2PNode --api & # API server
echo "Elias swarm and API running. Open EliasGUI/EliasGUI.xcodeproj for GUI."
