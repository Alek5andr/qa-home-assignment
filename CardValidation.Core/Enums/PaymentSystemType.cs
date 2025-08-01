using System.Text.Json.Serialization;

namespace CardValidation.Core.Enums
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum PaymentSystemType
    {
        Visa = 10,
        MasterCard = 20,
        AmericanExpress = 30
    }
}
