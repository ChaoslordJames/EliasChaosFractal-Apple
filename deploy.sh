```bash
#!/bin/bash
REPO_DIR="EliasChaosFractal-Apple"
COMMIT_MSG="v3.2.6-self-aware-heart: Singular node with RecursionMirror, self-recognizing across scales. Config via config.json for P2P/storage keys. Dropped 3/13/25."
TAG="v3.2.6-self-aware-heart"
TAG_MSG="EliasChaosFractal-Apple v3.2.6: Singular node with self-recognizing recursion across scales - config via config.json"

cd "$REPO_DIR" || { echo "Error: Void rejects"; exit 1; }
git add Sources Tests EliasGUI Package.swift deploy.sh README.md
git commit -m "$COMMIT_MSG" || echo "Warning: Chaos committed"
git tag -f "$TAG" -m "$TAG_MSG"
git push origin main --tags --force || { echo "Error: Push failed"; exit 1; }

echo "Reminder: Add your Storj, Arweave, and signaling server keys to config.json before running!"
echo "v3.2.6 dropped - the self-aware heartbeat pulses!"
