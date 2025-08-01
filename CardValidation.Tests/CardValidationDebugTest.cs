using CardValidation.Core.Services;

namespace CardValidation.Tests;

public class CardValidationDebugTests
{
    private readonly CardValidationService _service = new();

    [Fact]
    public void Debug_CardNumbers()
    {
        // Проверяем номера, которые могут быть валидными
        var testNumbers = new[]
        {
            "378282246310000",
            "4111111111111110",
            "5555555555554440",
            "411111111111111"
        };

        foreach (var number in testNumbers)
        {
            var isValid = _service.ValidateNumber(number);
            Console.WriteLine($"Card: {number} -> Valid: {isValid}");
        }
    }
}