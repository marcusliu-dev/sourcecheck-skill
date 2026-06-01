# SourceCheck

SourceCheck is a small, local-first skill and verifier for checking whether
draft claims are supported by the source text or citation evidence supplied to
an AI agent.

It is built for a narrow job: keep citations honest. It does not claim to prove
truth, completeness, expert review, legal review, clinical review, scientific
validity, or live web currentness.

## Why This Exists

AI-generated drafts often include references that look plausible while the
source text does not actually support the claim. SourceCheck makes that gap
explicit by asking agents to compare each claim against the provided cited
source text and return a bounded status.

## What You Get

- an installable [`sourcecheck` skill](skills/sourcecheck/SKILL.md);
- a deterministic local verifier in
  [`scripts/sourcecheck_verify.py`](scripts/sourcecheck_verify.py);
- synthetic claim/source fixtures in [`fixtures/](fixtures/);
- public eval fixtures under [`evals/sourcecheck/`](evals/sourcecheck/);
- a worked synthetic example in
  [`examples/sourcecheck-claim-ledger.md`](examples/sourcecheck-claim-ledger.md);
- public limitations and provenance docs under [`docs/`](docs/);
- a repository safety verifier in
  [`scripts/verify-public-safety.ps1`](scripts/verify-public-safety.ps1).

## Claim Statuses

SourceCheck uses explicit, conservative statuses:

- `SUPPORTED`: the cited source text supports the claim.
- `PARTIAL`: the cited source text supports only part of the claim.
- `UNSUPPORTED`: the cited source text contradicts or does not support the
  claim.
- `MISREPRESENTED`: the draft overstates, reverses, or distorts the cited
  source.
- `SOURCE_MISMATCH`: the citation points to the wrong source for the claim.
- `UNRETRIEVABLE`: the cited source text is missing or unavailable.
- `NEEDS_EXPERT_REVIEW`: the source may be relevant, but the claim requires
  expert judgment beyond this verifier.

## Quick Start

Run the deterministic verifier against the synthetic fixtures:

```powershell
py -3 scripts/sourcecheck_verify.py fixtures/supported.json fixtures/unsupported.json fixtures/uncertain.json fixtures/source_mismatch.json
```

Run the public safety verifier:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-public-safety.ps1
```

On systems where `python3` is the configured command, replace `py -3` with
`python3`.

## Skill Install Path

The reusable skill lives at:

```text
skills/sourcecheck
```

For tools that support installing skills from a GitHub repository, install that
folder as the skill package and invoke it explicitly when citation support
needs to be checked.

## Design Principles

- Check support against provided sources, not the whole world.
- Fail closed when source text is missing.
- Keep evidence and claim status separate from writing style.
- Use synthetic public examples unless rights and privacy are verified.
- Treat the deterministic verifier as a fixture and structure check, not a
  substitute for expert review.

## Project Status

This repository is a public SourceCheck v1 surface: skill package, deterministic
verifier, synthetic fixtures, examples, eval fixtures, provenance, limitations,
and public-safety checks under `MIT`.

It intentionally does not include CI, package registry publication, external API
calls, credentials, or real private source examples.
