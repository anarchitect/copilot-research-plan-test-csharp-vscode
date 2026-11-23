namespace Checkout;

public static class ShippingPolicy
{
    // Workshop seam: write tests before implementing the shipping rules.
    public static decimal Calculate(decimal subtotal, bool express) =>
        throw new NotImplementedException("Implement the shipping specification.");
}
