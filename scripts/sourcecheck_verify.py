#!/usr/bin/env python3
"""Deterministic verifier for SourceCheck synthetic fixtures."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


VALID_STATUSES = {
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


def classify_claim(claim: dict, sources: dict[str, dict]) -> tuple[str, list[str]]:
    citations = claim.get("citations", [])
    notes: list[str] = []

    if not citations:
        return "UNRETRIEVABLE", ["claim has no citation ids"]

    missing = [source_id for source_id in citations if source_id not in sources]
    if missing:
        return "UNRETRIEVABLE", [f"missing source ids: {', '.join(missing)}"]

    required_source = claim.get("requires_source_id")
    if required_source and required_source not in citations:
        return "SOURCE_MISMATCH", [
            f"claim requires source '{required_source}' but cites {', '.join(citations)}"
        ]

    cited_text = normalize(
        " ".join(str(sources[source_id].get("text", "")) for source_id in citations)
    )

    if claim.get("requires_expert_review"):
        return "NEEDS_EXPERT_REVIEW", ["claim is marked as requiring expert review"]

    for phrase in claim.get("misrepresented_if_source_contains", []):
        if normalize(phrase) in cited_text:
            return "MISREPRESENTED", [f"source contains limiting phrase: {phrase}"]

    for phrase in claim.get("unsupported_if_source_contains", []):
        if normalize(phrase) in cited_text:
            return "UNSUPPORTED", [f"source contains contradiction: {phrase}"]

    required_phrases = claim.get("support_phrases", [])
    if not required_phrases:
        return "NEEDS_EXPERT_REVIEW", ["claim has no deterministic support phrases"]

    found = [phrase for phrase in required_phrases if normalize(phrase) in cited_text]
    missing_phrases = [phrase for phrase in required_phrases if phrase not in found]

    if len(found) == len(required_phrases):
        notes.extend(f"found support phrase: {phrase}" for phrase in found)
        return "SUPPORTED", notes

    if found:
        notes.extend(f"found support phrase: {phrase}" for phrase in found)
        notes.extend(f"missing support phrase: {phrase}" for phrase in missing_phrases)
        return "PARTIAL", notes

    return "UNSUPPORTED", [
        f"missing support phrase: {phrase}" for phrase in required_phrases
    ]


def verify_fixture(path: Path) -> tuple[bool, dict]:
    fixture = load_fixture(path)
    sources = source_map(fixture)
    results = []
    ok = True

    for claim in fixture.get("claims", []):
        actual, notes = classify_claim(claim, sources)
        expected = claim.get("expected_status")
        claim_ok = expected in VALID_STATUSES and actual == expected
        ok = ok and claim_ok
        results.append(
            {
                "claim_id": claim.get("id"),
                "expected_status": expected,
                "actual_status": actual,
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
                    + str(result["expected_status"])
                    + ", actual "
                    + str(result["actual_status"])
                )

    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())
