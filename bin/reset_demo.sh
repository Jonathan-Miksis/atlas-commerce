#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# reset_demo.sh — resets the demo to a clean state for another practice run
# Usage: bash bin/reset_demo.sh
# Run from the root of the atlas-commerce repo
# ─────────────────────────────────────────────────────────────────────────────
set -e

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
git fetch origin
git reset --hard origin/main

# ── 2. Delete old branches locally and remotely ──────────────────────────────
echo "→ Removing old demo branches..."
for branch in "$GREEN_BRANCH" "$RED_BRANCH"; do
  git branch -D "$branch" 2>/dev/null && echo "  deleted local: $branch" || echo "  no local branch: $branch"
  git push origin --delete "$branch" 2>/dev/null && echo "  deleted remote: $branch" || echo "  no remote branch: $branch"
done

# ── 3. Create demo/failing-test FIRST (RED — fails CI) ───────────────────────
echo ""
echo "→ Creating $RED_BRANCH..."
git checkout -b "$RED_BRANCH"

# Introduce deliberate bug using Ruby: assert 75.00 instead of correct 80.00
ruby -i -e "
  \$stdout = \$stderr
  content = ARGF.read
  content = content.gsub(
    'expect(product.discounted_price(20)).to eq(80.00)',
    'expect(product.discounted_price(20)).to eq(75.00)'
  )
  print content
" spec/models/product_spec.rb

git add spec/models/product_spec.rb
git commit -m "feat: update discount calculation for Q4 flash sale

Applying promotional pricing for Q4 flash sale campaign.
Updated expected discount calculation to reflect new rates."

git push origin "$RED_BRANCH"
echo "  ✓ $RED_BRANCH pushed"

# ── 4. Create feature/add-bulk-pricing LAST (GREEN — passes CI) ──────────────
echo ""
echo "→ Creating $GREEN_BRANCH..."
git checkout main
git checkout -b "$GREEN_BRANCH"

# Append bulk_price method to Product model using Ruby
ruby -i -e "
  content = ARGF.read
  method_code = %q(
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
end
)
  content = content.rstrip.delete_suffix('end').rstrip + \"\n\n\" + method_code
  print content
" app/models/product.rb

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

# ── 5. Back to main ──────────────────────────────────────────────────────────
git checkout main

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Reset complete! Ready for another practice run.                ║"
echo "║                                                                  ║"
echo "║  Go to: github.com/Jonathan-Miksis/atlas-commerce               ║"
echo "║                                                                  ║"
echo "║  Open PRs in this order:                                        ║"
echo "║    1. demo/failing-test        ← shows red CI fail             ║"
echo "║    2. feature/add-bulk-pricing ← shows green, merge this one   ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
