using Xunit;

namespace Checkout.Tests;

public class OrderTotalsTests
{
    [Theory]
    [InlineData("2.50", 3, "7.50")]
    [InlineData("0", 3, "0")]
    [InlineData("2.50", 0, "0")]
    [InlineData("1.005", 1, "1.01")]
    [InlineData("1.004", 2, "2.01")]
    public void Subtotal_rounds_the_product(string price, int quantity, string expected)
    {
        Assert.Equal(Parse(expected), OrderTotals.Subtotal(Parse(price), quantity));
    }

    [Fact]
    public void Negative_price_is_rejected()
    {
        var error = Assert.Throws<ArgumentOutOfRangeException>(
            () => OrderTotals.Subtotal(-0.01m, 1));
        Assert.Equal("unitPrice", error.ParamName);
    }

    [Fact]
    public void Negative_quantity_is_rejected()
    {
        var error = Assert.Throws<ArgumentOutOfRangeException>(
            () => OrderTotals.Subtotal(1m, -1));
        Assert.Equal("quantity", error.ParamName);
    }

    [Fact]
    public void Money_rounds_negative_midpoints_away_from_zero()
    {
        Assert.Equal(-1.01m, Money.Round(-1.005m));
    }

    private static decimal Parse(string value) =>
        decimal.Parse(value, System.Globalization.CultureInfo.InvariantCulture);
}
