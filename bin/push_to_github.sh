#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# push_to_github.sh
# Run this AFTER bin/setup_demo.sh to create the private repo and push.
# Usage: bash bin/push_to_github.sh YOUR_GITHUB_TOKEN
# ─────────────────────────────────────────────────────────────────────────────
set -e

TOKEN="${1:-}"
OWNER="Jonathan-Miksis"
REPO="atlas-commerce"

if [[ -z "$TOKEN" ]]; then
  echo "Usage: bash bin/push_to_github.sh <your-github-token>"
  echo ""
  echo "Get a token at: https://github.com/settings/tokens"
  echo "Required scope: repo"
  exit 1
fi

echo "→ Creating private repository $OWNER/$REPO on GitHub..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO\",\"private\":true,\"description\":\"Atlas Commerce — B2B product catalog API (demo)\",\"auto_init\":false}")

HTTP_STATUS=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)

if [[ "$HTTP_STATUS" == "201" ]]; then
  echo "✓ Repository created: https://github.com/$OWNER/$REPO"
elif [[ "$HTTP_STATUS" == "422" ]]; then
  echo "ℹ  Repository already exists — continuing with push."
else
  echo "✗ Failed to create repository (HTTP $HTTP_STATUS)"
  echo "$BODY"
  exit 1
fi

echo "→ Setting remote origin..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://$TOKEN@github.com/$OWNER/$REPO.git"

echo "→ Pushing main branch..."
git push -u origin main

echo "→ Pushing demo branches..."
git push origin feature/add-bulk-pricing
git push origin demo/failing-test

# Clean the token from the remote URL immediately
git remote set-url origin "https://github.com/$OWNER/$REPO.git"

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Pushed successfully!                                        ║"
echo "║                                                               ║"
echo "║  Repo: https://github.com/$OWNER/$REPO        ║"
echo "║                                                               ║"
echo "║  Now do these 3 things in GitHub Settings:                   ║"
echo "║                                                               ║"
echo "║  1. Branch protection on main:                               ║"
echo "║     Settings → Branches → Add rule                           ║"
echo "║     ✓ Require status checks (lint, test, build)              ║"
echo "║     ✓ Require branches to be up to date                      ║"
echo "║     ✓ Do not allow bypassing                                  ║"
echo "║                                                               ║"
echo "║  2. Create 'staging' environment:                            ║"
echo "║     Settings → Environments → New environment                ║"
echo "║     Name: staging  (no reviewers needed)                     ║"
echo "║                                                               ║"
echo "║  3. Create 'production' environment:                         ║"
echo "║     Settings → Environments → New environment                ║"
echo "║     Name: production                                         ║"
echo "║     ✓ Required reviewers → add yourself                      ║"
echo "║     ✓ Wait timer: 0 minutes                                  ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
