using CardValidation.Core.Enums;
using CardValidation.Core.Services;
using CardValidation.Core.Services.Interfaces;

namespace CardValidation.Tests;

public class CardValidationServiceTests
{
    private readonly ICardValidationService _service;

    public CardValidationServiceTests()
    {
        _service = new CardValidationService();
    }

    [Fact]
    public void ValidateNumber_ValidVisaCard_ReturnsTrue()
    {
        var visaCardNumber = "4111111111111111";
        var result = _service.ValidateNumber(visaCardNumber);
        Assert.True(result);
    }

    [Fact]
    public void ValidateNumber_ValidVisaCardWith13Digits_ReturnsTrue()
    {
        var visaCardNumber = "4111111111111";
        var result = _service.ValidateNumber(visaCardNumber);
        Assert.True(result);
    }

    [Fact]
    public void ValidateNumber_ValidMasterCard_ReturnsTrue()
    {
        var masterCardNumber = "5555555555554444";
        var result = _service.ValidateNumber(masterCardNumber);
        Assert.True(result);
    }

    [Fact]
    public void ValidateNumber_ValidMasterCardStartingWith2_ReturnsTrue()
    {
        var masterCardNumber = "2221001234567890";
        var result = _service.ValidateNumber(masterCardNumber);
        Assert.True(result);
    }

    [Fact]
    public void ValidateNumber_ValidAmericanExpress_ReturnsTrue()
    {
        var amexCardNumber = "378282246310005";
        var result = _service.ValidateNumber(amexCardNumber);
        Assert.True(result);
    }

    [Fact]
    public void ValidateNumber_ValidAmericanExpressStartingWith34_ReturnsTrue()
    {
        var amexCardNumber = "341111111111111";
        var result = _service.ValidateNumber(amexCardNumber);
        Assert.True(result);
    }

    [Theory]
    [InlineData("")]
    [InlineData("1234567890123456")]
    [InlineData("invalid")]
    [InlineData("123456789012345")]
    [InlineData("12345678901234567")]
    [InlineData("411111111111111")]
    [InlineData("555555555555444")]
    [InlineData("37828224631000")]
    [InlineData("311111111111111")]
    [InlineData("6111111111111111")]
    [InlineData("1111111111111111")]
    public void ValidateNumber_InvalidCardNumbers_ReturnsFalse(string cardNumber)
    {
        var result = _service.ValidateNumber(cardNumber);
        Assert.False(result);
    }

    [Fact]
    public void GetPaymentSystemType_ValidVisaCard_ReturnsVisa()
    {
        var visaCardNumber = "4111111111111111";
        var result = _service.GetPaymentSystemType(visaCardNumber);
        Assert.Equal(PaymentSystemType.Visa, result);
    }

    [Fact]
    public void GetPaymentSystemType_ValidMasterCard_ReturnsMasterCard()
    {
        var masterCardNumber = "5555555555554444";
        var result = _service.GetPaymentSystemType(masterCardNumber);
        Assert.Equal(PaymentSystemType.MasterCard, result);
    }

    [Fact]
    public void GetPaymentSystemType_ValidAmericanExpress_ReturnsAmericanExpress()
    {
        var amexCardNumber = "378282246310005";
        var result = _service.GetPaymentSystemType(amexCardNumber);
        Assert.Equal(PaymentSystemType.AmericanExpress, result);
    }

    [Theory]
    [InlineData("")]
    [InlineData("1234567890123456")]
    [InlineData("invalid")]
    public void GetPaymentSystemType_InvalidCardNumber_ThrowsNotImplementedException(string cardNumber)
    {
        Assert.Throws<NotImplementedException>(() => _service.GetPaymentSystemType(cardNumber));
    }

    [Theory]
    [InlineData("John Doe")]
    [InlineData("JANE SMITH")]
    [InlineData("Mary Jane Wilson")]
    [InlineData("A B C")]
    public void ValidateOwner_ValidNames_ReturnsTrue(string owner)
    {
        var result = _service.ValidateOwner(owner);
        Assert.True(result);
    }

    [Theory]
    [InlineData("")]
    [InlineData("John123")]
    [InlineData("John@Doe")]
    [InlineData("A B C D")]
    [InlineData("John Doe Smith Wilson")]
    [InlineData("John Doe Smith Johnson")]
    [InlineData("123")]
    [InlineData("John-Doe")]
    public void ValidateOwner_InvalidNames_ReturnsFalse(string owner)
    {
        var result = _service.ValidateOwner(owner);
        Assert.False(result);
    }

    [Theory]
    [InlineData("12/2025")]
    [InlineData("01/2030")]
    [InlineData("12/25")]
    [InlineData("01/30")]
    public void ValidateIssueDate_ValidFutureDates_ReturnsTrue(string issueDate)
    {
        var result = _service.ValidateIssueDate(issueDate);
        Assert.True(result);
    }

    [Theory]
    [InlineData("13/2025")]
    [InlineData("00/2025")]
    [InlineData("12/2020")]
    [InlineData("12/20")]
    [InlineData("invalid")]
    [InlineData("12-2025")]
    [InlineData("12 20 25")]
    [InlineData("25/12")]
    [InlineData("2025/12")]
    [InlineData("12.2025")]
    [InlineData("12 2025")]
    public void ValidateIssueDate_InvalidDates_ReturnsFalse(string issueDate)
    {
        var result = _service.ValidateIssueDate(issueDate);
        Assert.False(result);
    }

    [Theory]
    [InlineData("123")]
    [InlineData("1234")]
    public void ValidateCvc_ValidCvc_ReturnsTrue(string cvc)
    {
        var result = _service.ValidateCvc(cvc);
        Assert.True(result);
    }

    [Theory]
    [InlineData("")]
    [InlineData("12")]
    [InlineData("12345")]
    [InlineData("12a")]
    [InlineData("invalid")]
    public void ValidateCvc_InvalidCvc_ReturnsFalse(string cvc)
    {
        var result = _service.ValidateCvc(cvc);
        Assert.False(result);
    }
} 