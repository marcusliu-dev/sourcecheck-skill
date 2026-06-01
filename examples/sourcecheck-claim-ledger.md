# Synthetic SourceCheck Claim Ledger

This example uses fictional source text. It is designed to show the shape of a
SourceCheck review without exposing private, restricted, or real-source
material.

## Sources

| source_id | title | source text |
| --- | --- | --- |
| `src-hours` | Synthetic library hours notice | The demo library opens at 9 a.m. Monday through Friday. On Fridays, the library closes at 6 p.m. |
| `src-workshop` | Synthetic workshop notice | The workshop is free for students. General admission is ten credits. The notice does not mention lunch. |

## Draft Claims

| claim_id | draft claim | citation |
| --- | --- | --- |
| `claim-supported-001` | The demo library closes at 6 p.m. on Fridays. | `src-hours` |
| `claim-unsupported-001` | The workshop includes free lunch for every attendee. | `src-workshop` |

## SourceCheck Result

| claim_id | verdict | reason_code | evidence | next action |
| --- | --- | --- | --- | --- |
| `claim-supported-001` | `SUPPORTED` | `SUPPORTED` | The cited source says the library closes at 6 p.m. on Fridays. | Keep the claim. |
| `claim-unsupported-001` | `UNSUPPORTED` | `UNSUPPORTED` | The cited source says the notice does not mention lunch. | Remove or rewrite the claim. |

## Residual Limits

This example checks source support only. It does not prove that the fictional
library hours or workshop details are true in the world.
