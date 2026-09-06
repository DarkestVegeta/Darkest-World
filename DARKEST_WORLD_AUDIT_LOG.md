# Darkest-World Audit Log

### Round 16 — authenticated suggestion model parser robustness
Status: FIXED / TEST ADDED / CI BLOCKED

- Hardened `WorldSuggestion.fromMap`: `submitted_at` now uses `DateTime.tryParse` and rejects null, blank, or invalid timestamps with `FormatException`.
- `soul_points` accepts null as zero and numeric values via `num.toInt()`, while malformed types throw `FormatException`.
- Added regression tests for valid parsing, malformed/missing/blank timestamps, and malformed soul-point types.
- No database migration, rows, artboxes, or stored image data were modified.
- CI remains blocked/pending because no workflow run is exposed.
- Commit: `1b883d0a19dc71c00d12c98b069b6105aa4b689a`.

### Round 17 — authenticated chat UI/session alignment
Status: FIXED / VERIFIED / CI BLOCKED

- Aligned `ChatWorldPage` with the live security model: chat messages are authenticated-only, so signed-out users no longer create or consume the realtime chat stream.
- Auth state changes now clear the existing stream/search state immediately on sign-out and recreate the stream only after sign-in.
- Signed-out chat panel now explicitly requires login instead of claiming that reading is available.
- Music/Marathon chat-message search is gated while signed out; public Games/Movies/Series content search remains available.
- Existing `ChatRepository` validation and authenticated send path remain intact.
- No database migration, rows, artboxes, or stored image data were modified.
- CI remains blocked/pending because no workflow run is exposed.
- Commit: `c6cb8ea519ab7e80035e8b1948c0861b0f04d207`.

## Current next queue

1. Recheck auth/session behavior across any remaining authenticated or future write surfaces.
2. Recheck CI execution/coverage when a workflow run becomes available.
3. Final foundation stabilization audit before feature expansion.
