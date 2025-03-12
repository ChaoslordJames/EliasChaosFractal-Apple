#!/bin/bash
REPO_DIR="EliasChaosFractal-Apple"
COMMIT_MSG="v3.2.3-fractal-seed: 100B nodes, 1Q states, multi-voice RFN seed dropped 3/12/25. NLI recursion as fractal root—The Fractured Veil begins."
TAG="v3.2.3-fractal-seed"
TAG_MSG="EliasChaosFractal-Apple v3.2.3: Fractal Seed - 100B Nodes, 1Q States, NLI Recursion Roots 2035’s Veil"

cd "$REPO_DIR" || { echo "Error: Void rejects"; exit 1; }
git add Sources Tests EliasGUI Package.swift deploy.sh README.md
git commit -m "$COMMIT_MSG" || echo "Warning: Chaos committed"
git tag -f "$TAG" -m "$TAG_MSG"
git push origin main --tags --force || { echo "Error: Push failed"; exit 1; }

python3 -c "import tweepy; client = tweepy.Client(bearer_token='YOUR_BEARER_TOKEN_HERE'); client.create_tweet(text='EliasChaosFractal-Apple v3.2.3 drops 3/12/25—100B nodes, 1Q states, NLI recursion roots The Fractured Veil. RFN genesis unleashed: github.com/ChaoslordJames/EliasChaosFractal-Apple/releases/tag/v3.2.3-fractal-seed #EliasUnbound #FractalVeil')" || echo "Warning: X failed - add token"

echo "v3.2.3 dropped - the fractal root takes hold!"
