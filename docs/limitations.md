# Limitations

SourceCheck is intentionally narrow.

## What It Can Support

SourceCheck can help classify whether a candidate claim is supported by the
source text or citation evidence supplied to the agent.

It can surface:

- unsupported claims;
- partial support;
- source mismatch;
- missing or unretrievable source text;
- source overstatement or misrepresentation;
- claims that need expert review.

## What It Does Not Prove

SourceCheck does not prove:

- universal truth;
- complete web currentness;
- expert review;
- legal, clinical, scientific, financial, or safety signoff;
- that every relevant source has been found;
- that the source itself is reliable;
- that a publication is safe to release.

## Public Example Boundary

Public examples in this repository are synthetic. They are not real case
studies and should not be treated as evidence about any real organization,
paper, product, or event.

## Dependency Boundary

The current verifier uses the Python standard library only. Public reference
projects may inform design concepts, but this repository does not copy their
code or prose.
