# Research, plan, and test a C# feature in VS Code

Read a small checkout library, review a plan, then use tests to check a new
shipping policy. The core exercise is an estimated 20 minutes after setup.
One optional plan critique adds up to 5 minutes. These are teaching estimates,
not measured completion times; SDK downloads and account setup are excluded.

This complements a prompt-engineering lab. It does not repeat zero-shot,
one-shot, inline completion, or planted-bug repair. No custom instructions,
MCP server, preview feature, web-search tool, or paid model choice is required.

## Before the timer starts

- Install current stable [VS Code](https://code.visualstudio.com/download).
  Follow [Copilot setup](https://code.visualstudio.com/docs/setup/copilot)
  and sign in with a GitHub account that has Copilot access and available usage.
  Organization policy may restrict agents, models, or tools.
- Install [C# Dev Kit](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit).
  Complete any extension sign-in or license prompts before the exercise.
- Install a serviced [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0).
  .NET 10 is LTS. This repository targets `net10.0`; `global.json` accepts
  installed stable 10.0 SDKs from 10.0.100 onward, including later feature bands,
  but not 11.0. A machine with only .NET 11 needs .NET 10 installed alongside it.
- Install Git. Windows includes Windows PowerShell; macOS/Linux users need
  [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)
  for the replay check in step 5.
- Allow access to NuGet for the first restore. No app server or database runs.

Clone this repository and open its root folder in VS Code. Commands below use
PowerShell and relative paths that also work in PowerShell on macOS/Linux.

```powershell
git clone https://github.com/anarchitect/copilot-research-plan-test-csharp-vscode.git
cd copilot-research-plan-test-csharp-vscode
code .
dotnet --version
dotnet test tests/Checkout.Tests/Checkout.Tests.csproj --nologo
git switch -c lab/shipping
```

The SDK must report `10.0.xxx`. Expect **8 passed, 0 failed, 0 skipped**.
If it does not, fix setup before starting. This is a class library: `dotnet run`
on `src/Checkout` is not the workshop command.

Open Chat, start a session for this folder, and choose **Copilot** in
**Session Target**. Use its Ask, Plan, and Agent roles, not Cloud or the
deprecated Local harness. If a control is missing, check the current
[harness guide](https://code.visualstudio.com/docs/agents/run/agent-harnesses)
and your organization policy. Do not bypass policy or enable Autopilot.

## 1. Research without changing files (4 minutes)

Select **Ask**. Attach `src/Checkout/Money.cs`,
`src/Checkout/OrderTotals.cs`, `src/Checkout/ShippingPolicy.cs`,
`tests/Checkout.Tests/OrderTotalsTests.cs`, the test `.csproj`, and
`docs/shipping-spec.md` using Chat's file attachment control. Do not attach
`reference/`: those are answers, not evidence about the starter implementation.

Paste:

```text
Research this checkout library before we add shipping. Do not edit files.
Use only the attached starter code, test project, and shipping specification.
Report:
| Finding | File and line range | Symbol | What the evidence proves |
Then give:
1. Known facts about rounding, validation, existing tests, and the shipping stub.
2. Requirements from the shipping spec, clearly separated from implemented behavior.
3. Assumptions or unanswered questions. Do not invent line numbers or claim tests ran.
4. The official Decimal.Round(decimal, int, MidpointRounding) API link:
https://learn.microsoft.com/en-us/dotnet/api/system.decimal.round?view=net-10.0
Explain why Money.Round is relevant. If you cannot open the URL, say so.
```

Open two cited source locations and check the claims. Open the API link in your
browser if Chat cannot fetch it. Confirm it documents the explicit rounding
strategy overload, not just the two-argument overload. The source uses
`AwayFromZero`. These business rules are our exercise specification, not rules
mandated by .NET.

Ask uses read-only tools in this harness. `git status --short` should still
show no project edits. `/research` is an Insiders preview and is not part of
this stable-editor exercise.

## 2. Review and refine a plan (5 minutes)

Use `/plan` in the same conversation. Keep the spec and source files attached
if they are not already in context.

```text
/plan Implement docs/shipping-spec.md using the existing ShippingPolicy.Calculate
stub. Keep Money, OrderTotals, baseline tests, packages, and project files unchanged.
Phase 1: add only tests/Checkout.Tests/ShippingPolicyTests.cs, run it against the
stub, and stop with real failing-test output.
Phase 2: implement only src/Checkout/ShippingPolicy.cs after I explicitly request it.
Include boundary, rounding, express, negative-input, exception-parameter, and
decimal.MaxValue cases. Use xUnit v3 and invariant-culture decimal test data.
Identify affected files, specific test cases, exact commands, and unresolved choices.
Do not implement yet. Use the spec for decisions; no integrations or new abstractions.
```

Read the **Review Plan** card. Choose **Open Full Plan** if offered; labels may
differ by session. Before approving, submit this refinement in the card's
feedback area with **Submit Feedback**:

```text
Make the two approval gates explicit: tests first, implementation only on my
later request. Ensure validation occurs before rounding, so -0.001 is rejected.
List 49.994 and 49.995 separately and test express at the free-shipping threshold.
```

Check that the revised plan includes the feedback. Select **Approve Plan Only**
when offered, not **Implement Plan**, which starts implementation immediately.
If only an implementation action is available, do not select it. Tell Plan:
“The plan is approved for reference only. Do not execute it.” Then select
Agent for the bounded next step. A written request is not a permission setting:
review any tool approval separately.

## 3. Generate tests and see them fail (5 minutes)

Select **Agent** (the implementation mode may be labelled **Interactive**).
Paste:

```text
Execute phase 1 only from the reviewed plan. Create
tests/Checkout.Tests/ShippingPolicyTests.cs with at least twelve executed cases.
Use explicit expected fees from docs/shipping-spec.md, not values computed by
the production code. Include both express values for -0.001 and decimal.MaxValue.
Do not edit production code, baseline tests, reference files, or configuration.
Run dotnet test tests/Checkout.Tests/Checkout.Tests.csproj --nologo.
Stop after reporting the actual failed test names and why the stub causes them.
Do not implement ShippingPolicy yet, skip tests, or weaken assertions.
```

Review the diff and run that command yourself. The 8 baseline cases must remain
green and the new cases must fail against `NotImplementedException`. A compiler
error or NuGet failure is not the red-test checkpoint. Resolve test compilation
problems without implementing the feature.

If generation stalls, copy `reference/ShippingPolicyTests.cs.txt` to
`tests/Checkout.Tests/ShippingPolicyTests.cs` using the command in
[reference checkpoints](reference/answers.md#reference-fallback) and rerun. Label this as the
reference fallback, not successful AI generation.

## 4. Implement the approved feature (4 minutes)

```text
Execute phase 2 only. Implement ShippingPolicy.Calculate according to the
reviewed plan and docs/shipping-spec.md. Edit only src/Checkout/ShippingPolicy.cs.
Do not change tests or packages. Run the full test project and report actual results.
```

Review the implementation. Run:

```powershell
dotnet test tests/Checkout.Tests/Checkout.Tests.csproj --nologo
git diff -- src/Checkout tests/Checkout.Tests
```

All baseline and new cases must pass with none skipped. The reference path has
20 total cases. Your generated suite may have more. If needed, copy
`reference/ShippingPolicy.cs.txt` over the stub using the timestamp-safe command
in [reference checkpoints](reference/answers.md#reference-fallback) and rerun. This fallback completes
the C# path but does not verify that the model followed the prompt.

## 5. Check that the tests catch mistakes (2 minutes)

In the VS Code PowerShell terminal, run:

```powershell
./scripts/replay.ps1 -UseLearnerTests
```

The script copies your shipping tests into an isolated `.replay` folder inside
this repo. It checks the stub fails, the reference passes, and five incorrect
implementations fail: an exclusive threshold, omitted rounding, free express
shipping, validation after rounding, and the wrong exception parameter. It
restores green and deletes its working copy. It never overwrites your work.
This checks your tests against the reference, not your implementation; step 4
checks your implementation. A passing suite alone does not prove tests detect bugs.

If the script reports an undetected mutation, ask Agent to add the missing
spec-based assertion to your shipping tests only, then rerun both commands.
Keep the baseline tests intact. Test failures printed during replay are expected;
the script succeeds only if each intended red checkpoint is verified.

Finish by stating one verified research fact, one plan refinement, and one
incorrect implementation your tests caught.

## Optional: critique the plan (up to 5 extra minutes)

Before step 3, select Ask, attach the reviewed plan, and paste:

```text
Critique this plan against docs/shipping-spec.md. Return at most three issues:
| Issue | Spec evidence | Concrete revision |
Separate actual contradictions from preferences. Do not edit or implement.
Check rounding order, express precedence, and whether the tests could pass
with an incorrect threshold. Say "none found" if there is no supported issue.
```

Submit any supported revision to Plan, review it again, and keep the same
approval gates. Custom instructions are intentionally excluded from this lab.

## If something blocks you

| Problem | Next step |
| --- | --- |
| Compatible SDK not found | Run `dotnet --list-sdks`; install stable .NET 10 and reopen the terminal. Do not delete `global.json`. |
| Restore fails | Check NuGet connectivity and approved proxy settings. Run the setup test command again. |
| No Copilot / Plan selection | Check sign-in, extension updates, usage allowance, harness selection, and organization policy. Use the reference fallback if unavailable. |
| Chat makes extra edits | Reject those edits in the diff before continuing; keep only the two allowed feature files. |
| Script execution blocked | Review the script and follow your organization's PowerShell policy. Do not disable security controls. Ask the facilitator to run the replay on an approved machine. |
| Red stage produces no failing tests | Ensure `ShippingPolicyTests.cs` exists in the test project, has xUnit attributes, and calls the stub. |

The commands are the source of test results. Chat output is not evidence that
a command ran. To repeat without discarding useful work, use a fresh clone.

## Reference and maintenance

- [Reference research and plan](reference/answers.md)
- [Validation record](docs/validation.md), including what was not rehearsed
- Maintainer check: `./scripts/replay.ps1` runs the supplied reference path.
- GitHub Actions is configured for Windows and Linux baseline and replay checks.
  Check actual workflow results before claiming either CI environment passed.
- Current [planning controls](https://code.visualstudio.com/docs/agents/run/planning),
  [.NET SDK selection](https://learn.microsoft.com/en-us/dotnet/core/tools/global-json),
  [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core),
  and [xUnit v3 guide](https://xunit.net/docs/getting-started/v3/getting-started).
  The xUnit guide may show preview packages; this lab pins stable packages
  and uses the VSTest-compatible `dotnet test` route.
