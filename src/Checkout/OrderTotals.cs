namespace Checkout;

public static class OrderTotals
{
    public static decimal Subtotal(decimal unitPrice, int quantity)
    {
        if (unitPrice < 0)
            throw new ArgumentOutOfRangeException(nameof(unitPrice));
        if (quantity < 0)
            throw new ArgumentOutOfRangeException(nameof(quantity));

        return Money.Round(unitPrice * quantity);
    }
}
