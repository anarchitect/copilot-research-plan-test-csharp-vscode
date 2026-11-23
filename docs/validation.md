# Validation record

Checked on 2026-11-23 UTC.

## Starting point and scope

The public repository at `0384a50243cc141d92529c79e7e042ada9d2e820`
contained a two-line README and LICENSE. It described a 20-minute exercise but
contained no C# project, prompts, test cases, setup instructions, or executable
path. It could not yet be assessed as a runnable workshop.

This revision supplies a local class library exercise, not a deployed app.
The core time allocation is 4 + 5 + 5 + 4 + 2 = 20 minutes after setup.
An optional plan critique adds up to 5 minutes. No participant completion time
was measured. Restore and command durations are not workshop timing evidence.
There are no automatically loaded custom instruction files.

## Executed C# path

Environment: Windows, .NET SDK `10.0.404`, .NET runtime `10.0.15`,
PowerShell `7.7.0`. SDK `11.0.100` was also installed but was not selected:
`global.json` requested `10.0.100` with `latestFeature` and no prereleases.

Executed the baseline test command, added reference tests as the documented
fallback, observed red, wrote the reference implementation, observed green,
ran the learner-test replay, then restored the starter. Also ran the reference
replay independently on PowerShell 7 and built-in Windows PowerShell 5.1.

| Checkpoint | Total | Passed | Failed | Skipped |
| --- | ---: | ---: | ---: | ---: |
| Starter baseline | 8 | 8 | 0 | 0 |
| Reference tests against stub | 20 | 8 | 12 | 0 |
| Reference implementation | 20 | 20 | 0 | 0 |
| Exclusive threshold mutation | 20 | 18 | 2 | 0 |
| Missing rounding mutation | 20 | 19 | 1 | 0 |
| Free express mutation | 20 | 18 | 2 | 0 |
| Late validation mutation | 20 | 18 | 2 | 0 |
| Wrong parameter mutation | 20 | 18 | 2 | 0 |
| Restored reference | 20 | 20 | 0 | 0 |
| Restored starter solution | 8 | 8 | 0 | 0 |

Both `scripts/replay.ps1` modes completed successfully using the supplied
tests. Each replay checked TRX results, not just a nonzero exit code. The five
mutations compiled and caused assertion failures; baseline cases stayed green.
The replay working copies were deleted and the checked-in feature remains a stub.

The rehearsal caught a practical fallback bug: `Copy-Item` preserved an older
reference implementation timestamp, so an incremental build reused the stub.
The documented answer commands now use `Get-Content -Raw | Set-Content`.
The full fallback and learner replay passed after that correction.

`dotnet format Checkout.slnx --verify-no-changes --no-restore` and
`git diff --check` passed. Local Markdown file links were checked.

## Documentation facts checked

| Claim | Primary source |
| --- | --- |
| Copilot harness, Ask read-only, Agent implementation, Plan `/plan` | [Agent harnesses](https://code.visualstudio.com/docs/agents/run/agent-harnesses) |
| Plan review and feedback before implementation; approve-only action where offered | [Planning](https://code.visualstudio.com/docs/agents/run/planning) |
| `/research` is an Insiders preview, not a stable prerequisite | [Planning, research before planning](https://code.visualstudio.com/docs/agents/run/planning#_research-before-planning-preview) |
| Stable VS Code release exists; no fixed version is required by this lab | [Release notes](https://code.visualstudio.com/updates) redirected to 1.147, dated November 18, 2026 |
| Copilot sign-in, account access, usage, and policy requirements | [Copilot setup](https://code.visualstudio.com/docs/setup/copilot) |
| C# Dev Kit environment setup | [C# getting started](https://code.visualstudio.com/docs/csharp/get-started) |
| .NET 10 is LTS | [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core) |
| `latestFeature` stays within requested SDK major/minor | [global.json](https://learn.microsoft.com/en-us/dotnet/core/tools/global-json) |
| Explicit decimal precision and midpoint strategy | [Decimal.Round](https://learn.microsoft.com/en-us/dotnet/api/system.decimal.round?view=net-10.0) |
| xUnit v3 executable test projects and VSTest-compatible tooling | [xUnit v3 guide](https://xunit.net/docs/getting-started/v3/getting-started) |
| Current checkout and .NET setup Actions | [checkout README](https://github.com/actions/checkout) and [setup-dotnet README](https://github.com/actions/setup-dotnet); release tags v7 and v6 were resolved and pinned by SHA |

The guide's current examples use preview xUnit packages. This repository instead
pins stable `xunit.v3` 3.2.2, `xunit.runner.visualstudio` 3.1.5, and
`Microsoft.NET.Test.Sdk` 17.14.1. Their restore and execution were verified;
they are not claimed to be the latest package releases.

## Verification limits

- No interactive VS Code Chat session or AI-generated research, plan, or test
  response was rehearsed. Prompts and control names were checked against current
  official docs, not a captured UI interaction.
- The reference fallback is a complete executed C# path, not evidence that an
  AI model obeyed the approval gates, produced correct citations, or wrote tests.
- Linux and macOS were not executed locally. Windows/Linux CI is configured,
  but no remote workflow run is claimed before the branch is pushed.
- Downloads, first-time sign-in, organization controls, model latency, and
  participant reading speed can change completion time.
- Five detected mutations provide bounded evidence about these tests, not proof
  that every possible incorrect implementation will be caught.

## Live UI attempt

A disposable copy opened in the VS Code 1.147 Chat view with Copilot selected.
The UI exposed Ask and Agent through the agent picker, separately from the
Interactive and Plan mode menu. The README now explains how to find that picker.
A recurring Settings modal interrupted automation before the research prompt,
plan approval, and generated-test path could complete.
This attempt does not establish an end-to-end UI pass.
