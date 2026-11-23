# Research, plan, and test a C# feature in VS Code

Use the VS Code Chat view with the Copilot harness to research a checkout
library, review a plan, and test a new shipping policy.
Allow about 20 minutes after setup, plus 5 optional minutes for plan critique.
These are estimates; downloads and sign-in are excluded.

This complements the [prompt-engineering lab](https://github.com/anarchitect/copilot-prompt-engineering-csharp-vscode).
No custom instructions or preview features are required.

## Before the timer starts

- Install current stable [VS Code](https://code.visualstudio.com/download).
  Follow [Copilot setup](https://code.visualstudio.com/docs/setup/copilot)
  and sign in with a GitHub account that has Copilot access and available usage.
  Organization policy may restrict agents, models, or tools.
- Install [C# Dev Kit](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit).
  Complete any extension sign-in or license prompts before the exercise.
- Install a serviced [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0).
  This project needs .NET 10, even if .NET 11 is already installed.
- Install Git. Windows includes Windows PowerShell; macOS/Linux users need
  [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)
  for the replay check in step 5.
- Allow access to NuGet for the first restore. No app server or database runs.

Clone and open the repository:

```powershell
git clone https://github.com/anarchitect/copilot-research-plan-test-csharp-vscode.git
cd copilot-research-plan-test-csharp-vscode
code .
```

Review the sample before accepting VS Code's workspace trust prompt.
Run these commands in the VS Code PowerShell terminal:

```powershell
dotnet --version
dotnet test tests/Checkout.Tests/Checkout.Tests.csproj --nologo
git switch -c lab/shipping
```

The SDK must report `10.0.xxx`. Expect **8 passed, 0 failed, 0 skipped**.
If it does not, fix setup before starting.

Open the **Chat view** with `Ctrl+Alt+I` on Windows/Linux or
`Control+Command+I` on macOS. Select **New Chat** (`+`) for this folder.

| Control | Choose |
| --- | --- |
| Session Target | Copilot |
| Agent | Ask to start |
| Language model | Auto, or an available model |
| Permissions | Manual permissions |

Use this Chat view throughout, including `/plan`. Do not choose Cloud or Local.
Review requested actions and approve only those needed for the exercise.
Use only this sample code; never attach secrets or customer data.

If the agent picker is hidden, select **Add Context → Agent… → Ask**.
Click the **Ask** button when you later need **Agent**.
Use `/plan` for the planning step; the mode menu is a separate control.

## 1. Research without changing files (4 minutes)

Select **Ask**. Attach `src/Checkout/Money.cs`,
`src/Checkout/OrderTotals.cs`, `src/Checkout/ShippingPolicy.cs`,
`tests/Checkout.Tests/OrderTotalsTests.cs`, the test `.csproj`, and
`docs/shipping-spec.md` using **Add Context** or the `#` file picker. Do not attach
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

Open two cited source locations and check the claims. Check the API link in your
browser if Chat cannot fetch it. It must document the overload with an explicit
rounding strategy. The source uses `AwayFromZero`; the shipping rules come from
our spec, not .NET.

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
"The plan is approved for reference only. Do not execute it." Then select
Agent for the next step. Plan approval and tool approval are separate.

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

The script tests a disposable copy. The stub must fail, the reference must pass,
and five faulty implementations must fail. It checks threshold, rounding,
express shipping, validation order, and exception parameter mistakes.
It deletes the copy without changing your files. Step 4 checks your implementation;
this step checks whether your tests detect mistakes.

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

Read actual terminal results rather than relying on Chat's summary.
To repeat the exercise, use a fresh clone.

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
