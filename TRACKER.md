# SourceCheck Tracker

Status: Current repository surface includes a reusable `sourcecheck` skill, a
deterministic verifier, synthetic fixtures, public eval fixtures, examples,
documentation, and sanitization checks.

## Current Claim Ceiling

`public_sourcecheck_local_surface_verifier_backed`

Current evidence can prove that this repository contains the listed public
surface and that deterministic local checks pass. It does not prove universal
truth checking, expert review, live web completeness, package registry
publication, CI coverage, or production runtime safety.

## Publication Snapshot

- owner: `marcusliu-dev`
- repository: `sourcecheck-skill`
- visibility: `public`
- license: `MIT`
- repository model: docs plus installable skill package plus deterministic
  verifier
- installable skill path: `skills/sourcecheck`
- examples: synthetic-only

## Current Surface

- `README.md`
- `LICENSE`
- `.gitignore`
- `TRACKER.md`
- `skills/sourcecheck/SKILL.md`
- `skills/sourcecheck/agents/openai.yaml`
- `scripts/sourcecheck_verify.py`
- `scripts/verify-public-safety.ps1`
- `fixtures/supported.json`
- `fixtures/unsupported.json`
- `fixtures/uncertain.json`
- `fixtures/source_mismatch.json`
- `examples/sourcecheck-claim-ledger.md`
- `evals/sourcecheck/sourcecheck-public-happy-path.yaml`
- `evals/sourcecheck/sourcecheck-public-misuse-overclaim.yaml`
- `evals/sourcecheck/sourcecheck-public-trajectory.yaml`
- `docs/limitations.md`
- `docs/provenance.md`
- `docs/release-readiness.md`
- `docs/reference-scan.md`

## Active Boundaries

- no real private examples;
- no hidden source retrieval;
- no external API calls;
- no credentials;
- no package registry publication;
- no CI automation in v1;
- no claim that SourceCheck proves truth, completeness, expert review, legal
  review, clinical review, or scientific validity.

## Verification Snapshot

- required files and directories are present;
- synthetic fixtures validate against the deterministic verifier;
- public eval fixtures are structurally checked;
- blocked private markers and local path patterns are scanned;
- markdown links are checked;
- claim ceiling consistency is checked;
- examples remain synthetic-only.
