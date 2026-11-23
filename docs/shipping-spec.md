# Shipping rules

Implement `Checkout.ShippingPolicy.Calculate(decimal subtotal, bool express)`.
Return the shipping fee, not the combined order total.

1. Reject every negative subtotal with `ArgumentOutOfRangeException`.
   Its `ParamName` must be `subtotal`, including when express is true.
2. Round a nonnegative subtotal with `Money.Round` before comparing it
   with the free-shipping threshold.
3. Express shipping always costs `12m`, even when the rounded subtotal
   reaches the threshold.
4. Standard shipping costs `5m` below `50m` and `0m` at or above `50m`.
5. Zero is valid. There is no maximum subtotal. `decimal.MaxValue` is valid.

| Raw subtotal | Express | Fee | Reason |
| --- | --- | --- | --- |
| `0m` | false | `5m` | Valid, below threshold |
| `49.99m` | false | `5m` | Below threshold |
| `50m` | false | `0m` | Threshold is inclusive |
| `50.01m` | false | `0m` | Above threshold |
| `49.994m` | false | `5m` | Rounds to 49.99 |
| `49.995m` | false | `0m` | Rounds to 50.00 |
| `0m` | true | `12m` | Express overrides free shipping |
| `50m` | true | `12m` | Express overrides free shipping |
| `-0.001m` | either | Exception | Validate before rounding |

No UI, database, HTTP service, currency conversion, or new package is needed.
Do not change `Money`, `OrderTotals`, their tests, or project configuration.
