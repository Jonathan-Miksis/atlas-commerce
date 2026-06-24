#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# reset_demo.sh — resets the demo to a clean state for another practice run
# Usage: bash bin/reset_demo.sh
# ─────────────────────────────────────────────────────────────────────────────
set -e

REMOTE="origin"
GREEN_BRANCH="feature/add-bulk-pricing"
RED_BRANCH="demo/failing-test"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║      Atlas Commerce — Demo Reset             ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── 1. Sync main ─────────────────────────────────────────────────────────────
echo "→ Syncing main with GitHub..."
git checkout main
git pull origin main

# ── 2. Delete branches locally and remotely ──────────────────────────────────
echo "→ Removing old demo branches..."

for branch in "$GREEN_BRANCH" "$RED_BRANCH"; do
  # Delete locally if exists
  git branch -D "$branch" 2>/dev/null && echo "  deleted local: $branch" || echo "  no local: $branch"
  # Delete remotely if exists
  git push origin --delete "$branch" 2>/dev/null && echo "  deleted remote: $branch" || echo "  no remote: $branch"
done

# ── 3. Recreate feature/add-bulk-pricing (GREEN — passes CI) ─────────────────
echo ""
echo "→ Creating $GREEN_BRANCH..."
git checkout -b "$GREEN_BRANCH"

python3 -c "
content = open('app/models/product.rb').read()
method = '''

  def bulk_price(quantity)
    raise ArgumentError, 'Quantity must be positive' unless quantity.positive?

    discount = case quantity
               when 1..9   then 0
               when 10..49 then 5
               when 50..99 then 10
               else 15
               end
    discounted_price(discount)
  end
end'''
content = content.rstrip().rstrip('end').rstrip() + method
open('app/models/product.rb', 'w').write(content)
"

git add app/models/product.rb
git commit -m "feat: add bulk pricing tiers to Product model

Products now support quantity-based pricing:
- 1-9 units:   list price
- 10-49 units: 5% discount
- 50-99 units: 10% discount
- 100+ units:  15% discount

Closes #12"

git push origin "$GREEN_BRANCH"
echo "  ✓ $GREEN_BRANCH pushed"

# ── 4. Recreate demo/failing-test (RED — fails CI) ───────────────────────────
echo ""
echo "→ Creating $RED_BRANCH..."
git checkout main

git checkout -b "$RED_BRANCH"

# Introduce deliberate bug: wrong expected value (75.00 instead of correct 80.00)
python3 -c "
content = open('spec/models/product_spec.rb').read()
content = content.replace(
    'expect(product.discounted_price(20)).to eq(80.00)',
    'expect(product.discounted_price(20)).to eq(75.00)'
)
open('spec/models/product_spec.rb', 'w').write(content)
"

git add spec/models/product_spec.rb
git commit -m "feat: update discount calculation for Q4 flash sale

Applying promotional pricing for Q4 flash sale campaign.
Updated expected discount calculation to reflect new rates."

git push origin "$RED_BRANCH"
echo "  ✓ $RED_BRANCH pushed"

# ── 5. Back to main ──────────────────────────────────────────────────────────
git checkout main

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Reset complete! Ready for another practice run.            ║"
echo "║                                                              ║"
echo "║  Branches ready on GitHub:                                  ║"
echo "║    demo/failing-test        ← open this PR first (red)     ║"
echo "║    feature/add-bulk-pricing ← open this PR second (green)  ║"
echo "║                                                              ║"
echo "║  Go to github.com/Jonathan-Miksis/atlas-commerce            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
