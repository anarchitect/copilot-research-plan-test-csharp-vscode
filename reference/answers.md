# Reference checkpoints

Use these if you are stuck or facilitating the workshop. They are not a model
transcript. The `.cs.txt` files are outside compilation until copied to a project.

## Research evidence

Line ranges refer to the starter files. Recheck them after editing.

| Finding | File and line range | Symbol | What the evidence proves |
| --- | --- | --- | --- |
| Explicit rounding policy | `src/Checkout/Money.cs:5-6` | `Money.Round` | Uses two decimal places and `MidpointRounding.AwayFromZero` |
| Validation before multiplication | `src/Checkout/OrderTotals.cs:5-12` | `OrderTotals.Subtotal` | Rejects negative price and quantity, then rounds their product |
| Unimplemented seam | `src/Checkout/ShippingPolicy.cs:6-7` | `ShippingPolicy.Calculate` | Always throws `NotImplementedException`; shipping rules are not implemented |
| Existing regression cases | `tests/Checkout.Tests/OrderTotalsTests.cs:7-37` | `OrderTotalsTests` | Five theory rows plus three facts cover arithmetic, rounding, and invalid arguments |
| Culture-independent data | `tests/Checkout.Tests/OrderTotalsTests.cs:40-41` | `Parse` | Decimal strings are parsed with `InvariantCulture` |
| Test tooling | `tests/Checkout.Tests/Checkout.Tests.csproj:3,11-16` | `TargetFramework`, `PackageReference`, `ProjectReference` | Targets .NET 10 and references xUnit v3, VSTest tooling, and the library |

Known source facts are not execution results. Running the baseline command is
what establishes 8 passing cases.

The shipping specification requires negative validation before rounding,
rounded-threshold comparison, and express precedence. None of these behaviors
exist in the shipping stub. The fixed fees are exercise requirements, not
inferences from existing code.

The [Decimal.Round overload](https://learn.microsoft.com/en-us/dotnet/api/system.decimal.round?view=net-10.0)
accepts the decimal amount, precision, and midpoint strategy. Reuse `Money.Round`
instead of introducing a different midpoint policy.

Assumptions: this is a single-currency teaching library, and no real checkout
integration is requested. There are no unresolved business choices for the
bounded feature because `docs/shipping-spec.md` supplies them. That does not
establish suitability for a production shop.

## Reviewed plan

1. Leave existing code, baseline tests, and package references unchanged.
2. Create only `tests/Checkout.Tests/ShippingPolicyTests.cs`.
   Cover the eight explicit fee rows, both express values for `-0.001m`,
   the exception parameter name, and both express values for `decimal.MaxValue`.
3. Run `dotnet test tests/Checkout.Tests/Checkout.Tests.csproj --nologo`.
   Expect 8 passed and 12 failed for the reference tests against the stub.
   Stop. The learner must see this checkpoint before implementation.
4. After a separate learner request, edit only `src/Checkout/ShippingPolicy.cs`.
   Validate the raw subtotal, round it with `Money.Round`, then apply express
   precedence and the inclusive standard threshold.
5. Run the same test command. Expect 20 passed and none skipped for the reference.
6. Run `./scripts/replay.ps1 -UseLearnerTests` to check the unchanged shipping
   tests against five wrong implementations in a disposable working copy.

The refinement makes validation order and approval gates explicit. “Write tests”
without named examples would not distinguish `49.994m` from `49.995m`.

## Reference fallback

Run each stage separately from the repository root, reading its result before
continuing. These commands replace the learner's shipping test file and stub:
save your own attempt elsewhere first if you want to keep it.

```powershell
Get-Content reference/ShippingPolicyTests.cs.txt -Raw | Set-Content tests/Checkout.Tests/ShippingPolicyTests.cs
dotnet test tests/Checkout.Tests/Checkout.Tests.csproj --nologo
# Expected: 8 passed, 12 failed against the starter stub.
```

Only after the red checkpoint:

```powershell
Get-Content reference/ShippingPolicy.cs.txt -Raw | Set-Content src/Checkout/ShippingPolicy.cs
dotnet test tests/Checkout.Tests/Checkout.Tests.csproj --nologo
./scripts/replay.ps1 -UseLearnerTests
# Expected: 20 passed, then a successful replay with intended failing phases.
```

To check the reference without changing your files, run `./scripts/replay.ps1`.
Neither route is evidence that a model produced the answer or obeyed plan gates.

The answer commands write fresh timestamps. `Copy-Item` can preserve
an older answer-file timestamp and leave an incremental build running the stub.
