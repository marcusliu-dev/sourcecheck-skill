# Provenance

Status: Public-surface provenance recorded for the current repository.

## Purpose

This document records provenance for the public files currently present in this
repository and the boundaries used to keep the public surface generic.

## Public-Surface Provenance Summary

| surface | provenance |
| --- | --- |
| `README.md` | Written locally as public-facing overview text for SourceCheck. |
| `LICENSE` | Standard MIT license text added after explicit license choice. |
| `.gitignore` | Written locally for ordinary local cache and secret-file exclusions. |
| `TRACKER.md` | Written locally as the bounded public release ledger. |
| `skills/sourcecheck/SKILL.md` | Written locally as a public-safe skill for checking support against provided source text. |
| `skills/sourcecheck/agents/openai.yaml` | Written locally as public skill metadata with implicit invocation disabled. |
| `scripts/sourcecheck_verify.py` | Written locally as a deterministic verifier for synthetic fixtures. |
| `scripts/verify-public-safety.ps1` | Written locally as a deterministic public-safety and sanitization verifier. |
| `fixtures/*.json` | Written locally as synthetic claim/source fixtures. |
| `examples/sourcecheck-claim-ledger.md` | Written locally as a synthetic example. |
| `evals/sourcecheck/*.yaml` | Written locally as public golden, misuse, and trajectory fixtures. |
| `docs/limitations.md` | Written locally to define public claim boundaries. |
| `docs/provenance.md` | Written locally as this provenance record. |
| `docs/release-readiness.md` | Written locally as the release-state record. |
| `docs/reference-scan.md` | Written locally as a public reference and no-copy boundary record. |

## Source Boundaries

- This repository contains generic public material only.
- Public examples are synthetic-only.
- No private repository paths, private trackers, unpublished prompts,
  restricted source text, credentials, or real private examples are intended
  for this repository.
- Public reference tools may inform design concepts, but their code and prose
  are not copied into this repository.

## Provenance Gaps

No unresolved provenance gap is currently known for the files listed above.

If a future gap is found, record it here before making broader readiness or
publication claims.
