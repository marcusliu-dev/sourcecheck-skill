# Release Readiness

Status: Current public repository surface includes a reusable SourceCheck
skill, deterministic verifier, synthetic fixtures, public eval fixtures,
documentation, and a public-safety verifier.

## Current Scope

The current repository surface includes:

- `README.md`
- `LICENSE`
- `.gitignore`
- `TRACKER.md`
- `skills/sourcecheck/SKILL.md`
- `skills/sourcecheck/agents/openai.yaml`
- `scripts/sourcecheck_verify.py`
- `scripts/verify-public-safety.ps1`
- synthetic fixtures under `fixtures/`
- a synthetic example under `examples/`
- public eval fixtures under `evals/sourcecheck/`
- `docs/limitations.md`
- `docs/provenance.md`
- `docs/release-readiness.md`
- `docs/reference-scan.md`

## Current Release Claim

The current release claim is narrow and explicit:

- the public repository is reachable at
  `https://github.com/marcusliu-dev/sourcecheck-skill`;
- the repository contains an installable SourceCheck skill package;
- the repository contains a deterministic verifier for synthetic fixtures;
- the verifier produces the primary verdicts `SUPPORTED`, `UNSUPPORTED`, and
  `UNCERTAIN`, with narrower reason codes for evidence handling;
- the public examples are synthetic-only;
- the documentation states the no-truth and no-expert-review limits;
- the local public-safety verifier checks required files, links, fixture
  behavior, claim ceiling, and obvious private-leakage patterns.

## Verified Evidence

Use these checks before any public release claim:

```powershell
py -3 scripts/sourcecheck_verify.py fixtures/supported.json fixtures/unsupported.json fixtures/uncertain.json fixtures/source_mismatch.json
powershell -ExecutionPolicy Bypass -File scripts/verify-public-safety.ps1
```

On systems where `python3` is the configured command, use `python3` instead of
`py -3`.

## Intentional Deferrals

The current v1 surface intentionally does not include:

- CI setup;
- package registry publication;
- external API calls;
- credential handling;
- real private source examples;
- automated expert review.

## Interpretation Rule

A passing verifier supports only the current repository surface. It should not
be stretched into claims about production safety, complete truth checking,
expert review, or current-source completeness.
