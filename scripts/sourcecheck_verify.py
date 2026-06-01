#!/usr/bin/env python3
"""Deterministic verifier for SourceCheck synthetic fixtures."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


VALID_VERDICTS = {
    "SUPPORTED",
    "UNSUPPORTED",
    "UNCERTAIN",
}

VALID_REASON_CODES = {
    "SUPPORTED",
    "PARTIAL",
    "UNSUPPORTED",
    "MISREPRESENTED",
    "SOURCE_MISMATCH",
    "UNRETRIEVABLE",
    "NEEDS_EXPERT_REVIEW",
}


def normalize(text: str) -> str:
    return " ".join(text.lower().split())


def load_fixture(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def source_map(fixture: dict) -> dict[str, dict]:
    return {source["id"]: source for source in fixture.get("sources", [])}


def classify_claim(claim: dict, sources: dict[str, dict]) -> tuple[str, str, list[str]]:
    citations = claim.get("citations", [])
    notes: list[str] = []

    if not citations:
        return "UNCERTAIN", "UNRETRIEVABLE", ["claim has no citation ids"]

    missing = [source_id for source_id in citations if source_id not in sources]
    if missing:
        return "UNCERTAIN", "UNRETRIEVABLE", [f"missing source ids: {', '.join(missing)}"]

    required_source = claim.get("requires_source_id")
    if required_source and required_source not in citations:
        return "UNSUPPORTED", "SOURCE_MISMATCH", [
            f"claim requires source '{required_source}' but cites {', '.join(citations)}"
        ]

    cited_text = normalize(
        " ".join(str(sources[source_id].get("text", "")) for source_id in citations)
    )

    if claim.get("requires_expert_review"):
        return "UNCERTAIN", "NEEDS_EXPERT_REVIEW", ["claim is marked as requiring expert review"]

    for phrase in claim.get("misrepresented_if_source_contains", []):
        if normalize(phrase) in cited_text:
            return "UNSUPPORTED", "MISREPRESENTED", [f"source contains limiting phrase: {phrase}"]

    for phrase in claim.get("unsupported_if_source_contains", []):
        if normalize(phrase) in cited_text:
            return "UNSUPPORTED", "UNSUPPORTED", [f"source contains contradiction: {phrase}"]

    required_phrases = claim.get("support_phrases", [])
    if not required_phrases:
        return "UNCERTAIN", "NEEDS_EXPERT_REVIEW", ["claim has no deterministic support phrases"]

    found = [phrase for phrase in required_phrases if normalize(phrase) in cited_text]
    missing_phrases = [phrase for phrase in required_phrases if phrase not in found]

    if len(found) == len(required_phrases):
        notes.extend(f"found support phrase: {phrase}" for phrase in found)
        return "SUPPORTED", "SUPPORTED", notes

    if found:
        notes.extend(f"found support phrase: {phrase}" for phrase in found)
        notes.extend(f"missing support phrase: {phrase}" for phrase in missing_phrases)
        return "UNCERTAIN", "PARTIAL", notes

    return "UNSUPPORTED", "UNSUPPORTED", [
        f"missing support phrase: {phrase}" for phrase in required_phrases
    ]


def verify_fixture(path: Path) -> tuple[bool, dict]:
    fixture = load_fixture(path)
    sources = source_map(fixture)
    results = []
    ok = True

    for claim in fixture.get("claims", []):
        actual_verdict, actual_reason_code, notes = classify_claim(claim, sources)
        expected_verdict = claim.get("expected_verdict", claim.get("expected_status"))
        expected_reason_code = claim.get("expected_reason_code", expected_verdict)
        claim_ok = (
            expected_verdict in VALID_VERDICTS
            and expected_reason_code in VALID_REASON_CODES
            and actual_verdict == expected_verdict
            and actual_reason_code == expected_reason_code
        )
        ok = ok and claim_ok
        results.append(
            {
                "claim_id": claim.get("id"),
                "expected_verdict": expected_verdict,
                "actual_verdict": actual_verdict,
                "expected_reason_code": expected_reason_code,
                "actual_reason_code": actual_reason_code,
                "ok": claim_ok,
                "notes": notes,
            }
        )

    return ok, {"fixture": str(path), "ok": ok, "results": results}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fixtures", nargs="+", help="Fixture JSON files to verify")
    parser.add_argument("--json", action="store_true", help="Print machine JSON")
    args = parser.parse_args()

    reports = []
    all_ok = True
    for fixture_name in args.fixtures:
        ok, report = verify_fixture(Path(fixture_name))
        reports.append(report)
        all_ok = all_ok and ok

    if args.json:
        print(json.dumps({"ok": all_ok, "reports": reports}, indent=2))
    else:
        print("SourceCheck fixture verification: " + ("pass" if all_ok else "fail"))
        for report in reports:
            print(f"- {report['fixture']}: {'pass' if report['ok'] else 'fail'}")
            for result in report["results"]:
                marker = "ok" if result["ok"] else "FAIL"
                print(
                    "  "
                    + marker
                    + " "
                    + str(result["claim_id"])
                    + ": expected "
                    + str(result["expected_verdict"])
                    + "/"
                    + str(result["expected_reason_code"])
                    + ", actual "
                    + str(result["actual_verdict"])
                    + "/"
                    + str(result["actual_reason_code"])
                )

    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())
