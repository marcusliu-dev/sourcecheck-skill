---
name: sourcecheck
description: >-
  Use when a draft contains citations, references, quoted source claims, or
  source-backed assertions and the task is to check whether each claim is
  supported by the provided source text or citation evidence.
---

# SourceCheck

## Purpose

SourceCheck checks whether candidate draft claims are supported by the source
text or citation evidence supplied to the agent.

It is not a universal fact checker. It does not prove truth, completeness,
expert review, legal review, clinical review, scientific validity, or live web
currentness.

## Use When

Use this skill when:

- a draft cites papers, articles, pages, datasets, manuals, or reports;
- the user asks whether citations are hallucinated, fabricated, unsupported, or
  misrepresented;
- an agent needs to audit a claim ledger before publishing or sending a draft;
- source text is available locally or has been provided by the user.

## Do Not Use When

Stop or ask for more evidence when:

- the source text is unavailable and the task requires support checking;
- the user wants expert, legal, medical, financial, or scientific signoff;
- the user asks for proof that a claim is true in the world rather than
  supported by the provided source;
- the task requires private or restricted sources that have not been supplied.

## Status Labels

Use one of these labels for each claim:

| label | meaning |
| --- | --- |
| `SUPPORTED` | The cited source text supports the claim. |
| `PARTIAL` | The cited source text supports only part of the claim. |
| `UNSUPPORTED` | The cited source text does not support or contradicts the claim. |
| `MISREPRESENTED` | The draft overstates, reverses, or distorts the source. |
| `SOURCE_MISMATCH` | The citation points to the wrong source for the claim. |
| `UNRETRIEVABLE` | The cited source text is missing or unavailable. |
| `NEEDS_EXPERT_REVIEW` | The source may be relevant, but the claim requires expert judgment. |

## Workflow

1. Frame the check.
   - Identify the draft, claims, cited sources, and intended output.
   - Confirm whether source text is actually available.
   - State that the check is bounded to provided sources.
2. Build a claim ledger.
   - Assign a stable `claim_id`.
   - Copy or summarize the exact claim.
   - Record citation IDs, source titles, source locations, and quoted evidence.
3. Compare each claim to the cited source.
   - Prefer direct source text over metadata.
   - Separate support, contradiction, missing evidence, and source mismatch.
   - Mark missing source text as `UNRETRIEVABLE`.
4. Return a compact table.
   - Include `claim_id`, status, cited source, evidence note, and next action.
   - Use `NEEDS_EXPERT_REVIEW` when support depends on specialist judgment.
5. Keep the claim narrow.
   - Do not say the claim is true unless the user asked for a separate fact
     check with appropriate evidence.
   - Do not infer support from a title, abstract, citation count, or source
     existence alone.

## Output Shape

```text
Scope:
Sources checked:
Claim results:
Unsupported or risky claims:
Missing sources:
Recommended edits:
Residual limits:
```

For `Claim results`, prefer a table:

```text
| claim_id | status | cited source | evidence | next action |
| --- | --- | --- | --- | --- |
```

## Safety Rules

- Treat source absence as a blocker, not as support.
- Quote only the minimum source text needed for evidence.
- Do not fabricate page numbers, URLs, titles, authors, or publication details.
- Do not use private or restricted content in public examples.
- Do not convert `PARTIAL`, `UNSUPPORTED`, or `UNRETRIEVABLE` into polished
  prose without warning the user.
- Use synthetic examples for public demonstrations unless rights and privacy
  have been checked.

## Deterministic Fixture Verifier

This repository includes `scripts/sourcecheck_verify.py` for deterministic
fixture checks. The script validates synthetic claim ledgers. It is useful for
testing the shape of SourceCheck decisions, but it is not a semantic proof
engine and does not replace human review.
