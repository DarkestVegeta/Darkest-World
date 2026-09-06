# Darkest-World Audit Log

### Round 16 — authenticated suggestion model parser robustness
Status: FIXED / TEST ADDED / CI BLOCKED

- Hardened `WorldSuggestion.fromMap`: `submitted_at` now uses `DateTime.tryParse` and rejects null, blank, or invalid timestamps with `FormatException`.
- `soul_points` accepts null as zero and numeric values via `num.toInt()`, while malformed types throw `FormatException`.
- Added regression tests for valid parsing, malformed/missing/blank timestamps, and malformed soul-point types.
- No database migration, rows, artboxes, or stored image data were modified.
- CI remains blocked/pending because no workflow run is exposed.
- Commit: `40d0b4c4e8ae68d2555dd48e95e94e4a9c6c79ef`.

## Current next queue

1. Recheck auth/session behavior across any remaining authenticated or future write surfaces.
2. Recheck CI execution/coverage when a workflow run becomes available.
3. Final foundation stabilization audit before feature expansion.
