# Recovery Procedures for Homebrew Tap

Procedures for diagnosing and recovering from bad formula updates, broken installations, and release failures.

## Quick Reference

| Scenario | Action | Time to Fix |
|----------|--------|-------------|
| Bad formula syntax | `git revert HEAD && git push` | < 2 min |
| Wrong checksum | Update SHA256 in formula, push | < 5 min |
| Bad release binary | Pin to previous version | < 5 min |
| Formula audit failure | Fix issues, re-validate | 5-15 min |
| Complete tap corruption | Reset to known-good commit | < 5 min |

## Procedure 1: Revert a Bad Formula Commit

When a formula update introduces syntax errors, wrong URLs, or bad checksums:

```bash
cd /data/projects/homebrew-tap

# 1. Identify the bad commit
git log --oneline -10 Formula/

# 2. Revert (creates a new commit, preserves history)
git revert HEAD  # If the latest commit is bad
# OR for a specific commit:
git revert <commit-sha>

# 3. Validate the reverted formula
ruby -c Formula/<tool>.rb
bash scripts/validate-formulas.sh

# 4. Push the fix
git push origin main && git push origin main:master
```

## Procedure 2: Fix a Wrong Checksum

When a release was re-tagged or the SHA256 in the formula doesn't match the actual binary:

```bash
# 1. Find the correct checksum from the release
curl -sL "https://github.com/Dicklesworthstone/<repo>/releases/download/v<version>/<binary>" | sha256sum

# 2. Update the formula
# Edit Formula/<tool>.rb - replace the sha256 value for the affected platform

# 3. Validate
ruby -c Formula/<tool>.rb
bash scripts/validate-formulas.sh

# 4. Commit and push
git add Formula/<tool>.rb
git commit -m "fix(<tool>): correct SHA256 checksum for v<version>"
git push origin main && git push origin main:master
```

## Procedure 3: Pin to a Known-Good Version

When the latest release has a critical bug and no fix is available yet:

```bash
# 1. Find the last known-good version
gh release list --repo Dicklesworthstone/<repo> --limit 5

# 2. Edit the formula to use the older version
# In Formula/<tool>.rb:
#   - Change `version "X.Y.Z"` to the older version
#   - Update all URL paths to match
#   - Update all sha256 values to match
#   - Add a comment: # PINNED: vX.Y.Z has critical bug, see issue #NNN

# 3. Validate and push
ruby -c Formula/<tool>.rb
git add Formula/<tool>.rb
git commit -m "fix(<tool>): pin to vOLDER due to critical bug in vNEWER"
git push origin main && git push origin main:master
```

## Procedure 4: Emergency Disable a Formula

When a tool has a critical vulnerability and must be taken offline immediately:

```ruby
# In Formula/<tool>.rb, add this line after the class declaration:
class Tool < Formula
  disable! date: "2026-02-09", because: "Critical issue, see https://github.com/..."
  # ... rest of formula unchanged
end
```

To re-enable: remove the `disable!` line, validate, and push.

## Procedure 5: Reset Tap to Known-Good State

When multiple bad commits need to be undone:

```bash
cd /data/projects/homebrew-tap

# 1. Find the last known-good commit
git log --oneline -20

# 2. Create a revert range (preserves history)
git revert --no-commit <bad-commit-sha>..HEAD
git commit -m "revert: roll back to <good-sha> due to multiple bad updates"

# 3. Push
git push origin main && git push origin main:master
```

## Diagnosing User-Reported Issues

### "SHA256 mismatch" Error

```bash
# Check what the formula expects vs what's actually at the URL
brew fetch --force dicklesworthstone/tap/<tool> 2>&1
# Compare the "Expected" and "Actual" SHA256 values
```

### "No bottle available" or Build Failure

```bash
# Check if the release exists
gh release view v<version> --repo Dicklesworthstone/<repo>

# Check if the binary URL is reachable
curl -sI "https://github.com/Dicklesworthstone/<repo>/releases/download/v<version>/<binary>" | head -5
```

### "Formula not found"

```bash
# Verify the tap is configured
brew tap | grep dicklesworthstone
# Re-add if missing
brew tap dicklesworthstone/tap
# Force update
brew update --force
```

## Prevention Checklist

Before pushing any formula change:

1. `ruby -c Formula/<tool>.rb` - Syntax check
2. `bash scripts/validate-formulas.sh` - Full validation
3. Verify release URLs are reachable (curl -sI)
4. Confirm SHA256 matches the actual binary
5. Run `bash scripts/test-formula.sh <tool>` if available

## Monitoring

The `auto-update.yml` workflow runs periodically to sync formulas with upstream releases. If it produces bad updates, disable it temporarily:

```bash
# Disable the workflow via GitHub
gh workflow disable auto-update.yml --repo Dicklesworthstone/homebrew-tap

# Re-enable after fixing
gh workflow enable auto-update.yml --repo Dicklesworthstone/homebrew-tap
```

## Post-Incident Template

After any recovery, document in a commit message or issue:

```
## Incident: <tool> v<version> - <date>
- **Detection**: How was it found (user report, CI, monitoring)
- **Impact**: Which platforms, how many users likely affected
- **Root Cause**: What went wrong (bad release, wrong SHA, syntax error)
- **Resolution**: What was done to fix it
- **Prevention**: What changes prevent recurrence
```
