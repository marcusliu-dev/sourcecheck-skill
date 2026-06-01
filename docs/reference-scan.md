# Public Reference Scan

Status: Concept-level public reference notes for the current SourceCheck v1
surface.

## Summary

Public source-checking and citation-verification projects already exist. This
repository does not claim that the SourceCheck name or idea is unique.

The v1 boundary is:

- local-first skill and verifier;
- support checking against provided source text;
- synthetic fixtures and examples;
- no copied third-party code or prose;
- no dependency on external APIs.

## Reference Boundary

Reference projects may inform high-level concepts such as citation support,
claim ledgers, source retrieval status, and unsupported-claim labels. They are
not imported, vendored, copied, or treated as active dependencies in this
repository.

## Current No-Copy Rule

If a future version wants to use third-party code, datasets, prompts, or prose,
it must first add a source, license, attribution, and adaptation record, then
expand the verifier to check the new surface.
