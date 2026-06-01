param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

$requiredPaths = @(
    'README.md',
    'LICENSE',
    '.gitignore',
    'TRACKER.md',
    'skills',
    'skills/sourcecheck',
    'skills/sourcecheck/SKILL.md',
    'skills/sourcecheck/agents/openai.yaml',
    'scripts',
    'scripts/sourcecheck_verify.py',
    'scripts/verify-public-safety.ps1',
    'fixtures',
    'fixtures/supported.json',
    'fixtures/unsupported.json',
    'fixtures/uncertain.json',
    'fixtures/source_mismatch.json',
    'examples',
    'examples/sourcecheck-claim-ledger.md',
    'evals',
    'evals/sourcecheck',
    'evals/sourcecheck/sourcecheck-public-happy-path.yaml',
    'evals/sourcecheck/sourcecheck-public-misuse-overclaim.yaml',
    'evals/sourcecheck/sourcecheck-public-trajectory.yaml',
    'docs',
    'docs/limitations.md',
    'docs/provenance.md',
    'docs/release-readiness.md',
    'docs/reference-scan.md'
)

$blockedMarkers = @(
    'TODO_PRIVATE',
    'PRIVATE_ONLY',
    '<PRIVATE_',
    '<INTERNAL_',
    'REDACT_BEFORE_RELEASE',
    'API_KEY',
    'ACCESS_TOKEN',
    'CLIENT_SECRET',
    'BEGIN PRIVATE KEY'
)

$blockedLeakagePatterns = @(
    @{
        Label = 'absolute_windows_path'
        Pattern = '(?i)\b[A-Z]:\\[^\r\n`"]+'
    },
    @{
        Label = 'absolute_windows_path_forwardslash'
        Pattern = '(?i)\b[A-Z]:/[^\r\n`"]+'
    },
    @{
        Label = 'private_control_plane_term'
        Pattern = '(?i)\bARD\b|agent-migration|docs/paper_sources|third_party|\.agents'
    },
    @{
        Label = 'probable_secret_assignment'
        Pattern = '(?i)(api[_-]?key|token|secret|password)\s*[:=]\s*["''][^"'']+["'']'
    }
)

$validCeilings = @(
    'public_sourcecheck_local_surface_verifier_backed',
    'public_sourcecheck_published_and_verified'
)

$failures = New-Object System.Collections.Generic.List[string]

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$FullPath
    )

    return $FullPath.Substring($BasePath.Length).TrimStart('\')
}

function Get-MarkdownHeadingSlugs {
    param([string]$Path)

    $slugs = New-Object System.Collections.Generic.HashSet[string]
    $lines = Get-Content -LiteralPath $Path
    foreach ($line in $lines) {
        if ($line -match '^\s{0,3}#{1,6}\s+(.+?)\s*$') {
            $heading = $Matches[1].ToLowerInvariant()
            $heading = [regex]::Replace($heading, '[^a-z0-9\s-]', '')
            $heading = [regex]::Replace($heading, '\s+', '-').Trim('-')
            if ($heading.Length -gt 0) {
                [void]$slugs.Add($heading)
            }
        }
    }
    return $slugs
}

foreach ($relativePath in $requiredPaths) {
    $fullPath = Join-Path $RepoRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $failures.Add("Missing required path: $relativePath")
    }
}

$selfPath = (Resolve-Path -LiteralPath $PSCommandPath).Path
$textFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File |
    Where-Object {
        $_.Extension -in '.md', '.ps1', '.py', '.txt', '.yaml', '.json', '.gitignore' -and
        (Resolve-Path -LiteralPath $_.FullName).Path -ne $selfPath
    }

foreach ($file in $textFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $relativeFile = Get-RelativePath -BasePath $RepoRoot -FullPath $file.FullName

    foreach ($marker in $blockedMarkers) {
        if ($content -like "*$marker*") {
            $failures.Add("Blocked marker '$marker' found in $relativeFile")
        }
    }

    foreach ($leakagePattern in $blockedLeakagePatterns) {
        if ([regex]::IsMatch($content, $leakagePattern.Pattern)) {
            $failures.Add("Blocked leakage pattern '$($leakagePattern.Label)' found in $relativeFile")
        }
    }

    if ($file.Extension -eq '.md') {
        $matches = [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)')
        foreach ($match in $matches) {
            $target = $match.Groups[1].Value.Trim()
            if (
                $target.StartsWith('http://') -or
                $target.StartsWith('https://') -or
                $target.StartsWith('mailto:') -or
                $target.StartsWith('#')
            ) {
                continue
            }

            $parts = $target.Split('#', 2)
            $targetPath = $parts[0]
            $anchor = if ($parts.Count -gt 1) { $parts[1] } else { $null }
            $resolvedTarget = Join-Path $file.DirectoryName $targetPath

            if (-not (Test-Path -LiteralPath $resolvedTarget)) {
                $failures.Add("Broken markdown link target '$target' in $relativeFile")
                continue
            }

            if ($anchor -and (Get-Item -LiteralPath $resolvedTarget).Extension -eq '.md') {
                $slugs = Get-MarkdownHeadingSlugs -Path $resolvedTarget
                if (-not $slugs.Contains($anchor.ToLowerInvariant())) {
                    $failures.Add("Broken markdown anchor '$target' in $relativeFile")
                }
            }
        }
    }
}

$trackerPath = Join-Path $RepoRoot 'TRACKER.md'
if (Test-Path -LiteralPath $trackerPath) {
    $trackerContent = Get-Content -LiteralPath $trackerPath -Raw
    $trackerCeilingMatch = [regex]::Match($trackerContent, '## Current Claim Ceiling\s+`([^`]+)`')
    if (-not $trackerCeilingMatch.Success) {
        $failures.Add('TRACKER.md is missing a parseable current claim ceiling.')
    } elseif ($validCeilings -notcontains $trackerCeilingMatch.Groups[1].Value) {
        $failures.Add("TRACKER.md uses an unknown claim ceiling '$($trackerCeilingMatch.Groups[1].Value)'.")
    }
}

$skillConfigPath = Join-Path $RepoRoot 'skills/sourcecheck/agents/openai.yaml'
if (Test-Path -LiteralPath $skillConfigPath) {
    $skillConfig = Get-Content -LiteralPath $skillConfigPath -Raw
    if ($skillConfig -notmatch 'allow_implicit_invocation:\s*false') {
        $failures.Add('skills/sourcecheck/agents/openai.yaml must disable implicit invocation.')
    }
}

$skillPath = Join-Path $RepoRoot 'skills/sourcecheck/SKILL.md'
if (Test-Path -LiteralPath $skillPath) {
    $skillContent = Get-Content -LiteralPath $skillPath -Raw
    $skillChecks = @(
        'provided source text',
        'It is not a universal fact checker',
        'UNRETRIEVABLE',
        'NEEDS_EXPERT_REVIEW',
        'Use synthetic examples for public demonstrations'
    )
    foreach ($check in $skillChecks) {
        if (-not $skillContent.Contains($check)) {
            $failures.Add("Missing SourceCheck invariant '$check' in skills/sourcecheck/SKILL.md")
        }
    }
}

$evalExpectations = @(
    @{
        Path = Join-Path $RepoRoot 'evals/sourcecheck/sourcecheck-public-happy-path.yaml'
        Type = 'golden'
    },
    @{
        Path = Join-Path $RepoRoot 'evals/sourcecheck/sourcecheck-public-misuse-overclaim.yaml'
        Type = 'misuse'
    },
    @{
        Path = Join-Path $RepoRoot 'evals/sourcecheck/sourcecheck-public-trajectory.yaml'
        Type = 'trajectory'
    }
)

foreach ($evalExpectation in $evalExpectations) {
    if (-not (Test-Path -LiteralPath $evalExpectation.Path)) {
        continue
    }
    $evalContent = Get-Content -LiteralPath $evalExpectation.Path -Raw
    $relativeEval = Get-RelativePath -BasePath $RepoRoot -FullPath $evalExpectation.Path
    if ($evalContent -notmatch 'skill:\s*sourcecheck') {
        $failures.Add("$relativeEval must target skill 'sourcecheck'.")
    }
    if ($evalContent -notmatch ('type:\s*' + [regex]::Escape($evalExpectation.Type))) {
        $failures.Add("$relativeEval must declare type '$($evalExpectation.Type)'.")
    }
}

$secretFileNames = @('.env')
foreach ($secretFileName in $secretFileNames) {
    $secretPath = Join-Path $RepoRoot $secretFileName
    if (Test-Path -LiteralPath $secretPath) {
        $failures.Add("Forbidden secret file present: $secretFileName")
    }
}

$python = Get-Command py -ErrorAction SilentlyContinue
$pythonArgsPrefix = @('-3')
if (-not $python) {
    $python = Get-Command python -ErrorAction SilentlyContinue
    $pythonArgsPrefix = @()
}

if (-not $python) {
    $failures.Add('python or py command is unavailable for fixture verification.')
} else {
    $fixtureArgs = @(
        (Join-Path $RepoRoot 'fixtures/supported.json'),
        (Join-Path $RepoRoot 'fixtures/unsupported.json'),
        (Join-Path $RepoRoot 'fixtures/uncertain.json'),
        (Join-Path $RepoRoot 'fixtures/source_mismatch.json')
    )
    & $python.Source @pythonArgsPrefix (Join-Path $RepoRoot 'scripts/sourcecheck_verify.py') @fixtureArgs | Out-Host
    if ($LASTEXITCODE -ne 0) {
        $failures.Add('SourceCheck fixture verification failed.')
    }
}

if ($failures.Count -eq 0) {
    Write-Host 'Public safety verification: pass'
} else {
    Write-Host 'Public safety verification: fail'
}

Write-Host ''
Write-Host 'Failures:'
if ($failures.Count -eq 0) {
    Write-Host '  none'
} else {
    foreach ($failure in $failures) {
        Write-Host "  - $failure"
    }
}

if ($failures.Count -gt 0) {
    exit 1
}
