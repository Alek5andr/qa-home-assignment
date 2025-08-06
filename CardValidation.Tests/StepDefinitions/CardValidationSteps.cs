using System.Net;
using System.Text;
using System.Text.Json;
using FluentAssertions;
using Reqnroll;

namespace CardValidation.Tests.Steps
{
    [Binding]
    public class CardValidationSteps
    {
        private readonly HttpClient _httpClient;
        private string _serviceUrl = string.Empty;
        private CreditCardRequest _creditCard = new();
        private HttpResponseMessage? _response;
        private string _responseContent = string.Empty;

        public CardValidationSteps()
        {
            _httpClient = new HttpClient();
        }

        [Given(@"the card validation service is available at credit card validation url")]
        public void GivenTheCardValidationServiceIsAvailableAt()
        {
            var baseUrl = Environment.GetEnvironmentVariable("TEST_API_URL") ?? "https://localhost:7135";
            _serviceUrl = $"{baseUrl}/CardValidation/card/credit/validate";
        }

        [Given(@"I have a credit card with the following details:")]
        public void GivenIHaveACreditCardWithTheFollowingDetails(Table table)
        {
            _creditCard = new CreditCardRequest();
            
            foreach (var row in table.Rows)
            {
                var field = row["Field"];
                var value = row["Value"];
                
                switch (field.ToLowerInvariant())
                {
                    case "owner":
                        _creditCard.Owner = value;
                        break;
                    case "number":
                        _creditCard.Number = value;
                        break;
                    case "date":
                        _creditCard.Date = value;
                        break;
                    case "cvv":
                        _creditCard.Cvv = value;
                        break;
                }
            }
        }

        [When(@"I send the validation request")]
        public async Task WhenISendTheValidationRequest()
        {
            var json = JsonSerializer.Serialize(_creditCard, new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            });
            
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            
            _response = await _httpClient.PostAsync(_serviceUrl, content);
            _responseContent = await _response.Content.ReadAsStringAsync();
        }

        [Then(@"the response status code should be (\d+)")]
        public void ThenTheResponseStatusCodeShouldBe(int expectedStatusCode)
        {
            _response.Should().NotBeNull();
            ((int)_response!.StatusCode).Should().Be(expectedStatusCode);
        }

        [Then(@"the response should indicate payment system type ""(.*)""")]
        public void ThenTheResponseShouldIndicatePaymentSystemType(string expectedPaymentSystem)
        {
            _response.Should().NotBeNull();
            _response!.StatusCode.Should().Be(HttpStatusCode.OK);
            
            Console.WriteLine($"Response content: {_responseContent}");
            
            try
            {
                if (_responseContent.Trim().StartsWith("\"") && _responseContent.Trim().EndsWith("\""))
                {
                    var paymentSystemType = JsonSerializer.Deserialize<string>(_responseContent);
                    paymentSystemType.Should().Be(expectedPaymentSystem);
                    return;
                }
                
                var responseAsObject = JsonSerializer.Deserialize<PaymentSystemResponse>(_responseContent, 
                    new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
                
                if (responseAsObject != null)
                {
                    responseAsObject.PaymentSystemType.Should().Be(expectedPaymentSystem);
                    return;
                }
                
                var responseAsDict = JsonSerializer.Deserialize<Dictionary<string, object>>(_responseContent,
                    new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
                
                if (responseAsDict != null)
                {
                    var paymentSystemField = responseAsDict.FirstOrDefault(kvp => 
                        kvp.Key.ToLowerInvariant().Contains("payment") || 
                        kvp.Key.ToLowerInvariant().Contains("type") ||
                        kvp.Key.ToLowerInvariant().Contains("system"));
                    
                    if (paymentSystemField.Key != null)
                    {
                        paymentSystemField.Value.ToString().Should().Be(expectedPaymentSystem);
                        return;
                    }
                }
                
                _responseContent.Should().Contain(expectedPaymentSystem);
            }
            catch (JsonException ex)
            {
                throw new InvalidOperationException($"Failed to deserialize response: {_responseContent}. Error: {ex.Message}");
            }
        }

        [Then(@"the response should contain error message ""(.*)""")]
        public void ThenTheResponseShouldContainErrorMessage(string expectedErrorMessage)
        {
            _response.Should().NotBeNull();
            _response!.StatusCode.Should().Be(HttpStatusCode.BadRequest);
            
            Console.WriteLine($"Error response content: {_responseContent}");
            
            try
            {
                var simpleErrorResponse = JsonSerializer.Deserialize<Dictionary<string, List<string>>>(_responseContent);
                
                if (simpleErrorResponse != null)
                {
                    var hasExpectedError = simpleErrorResponse.Values
                        .SelectMany(errors => errors)
                        .Any(error => error.Contains(expectedErrorMessage, StringComparison.OrdinalIgnoreCase));
                    
                    if (hasExpectedError)
                    {
                        hasExpectedError.Should().BeTrue();
                        return;
                    }
                }
                
                var errorResponse = JsonSerializer.Deserialize<ValidationErrorResponse>(_responseContent,
                    new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
                
                if (errorResponse?.Errors != null)
                {
                    var hasExpectedError = errorResponse.Errors.Values
                        .SelectMany(errors => errors)
                        .Any(error => error.Contains(expectedErrorMessage, StringComparison.OrdinalIgnoreCase));
                    
                    hasExpectedError.Should().BeTrue($"Expected error message '{expectedErrorMessage}' was not found in response errors");
                    return;
                }
            }
            catch (JsonException ex)
            {
                Console.WriteLine($"JSON deserialization failed: {ex.Message}");
            }
            
            _responseContent.Should().Contain(expectedErrorMessage, 
                $"Expected error message '{expectedErrorMessage}' was not found in response content: {_responseContent}");
        }

        [AfterScenario]
        public void Cleanup()
        {
            _response?.Dispose();
        }
    }

    public class CreditCardRequest
    {
        public string? Owner { get; set; }
        public string? Number { get; set; }
        public string? Date { get; set; }
        public string? Cvv { get; set; }
    }

    public class PaymentSystemResponse
    {
        public string? PaymentSystemType { get; set; }
        public string? PaymentSystem { get; set; }
        public string? Type { get; set; }
        public string? CardType { get; set; }
        public string? System { get; set; }
    }

    public class ValidationErrorResponse
    {
        public string Type { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public int Status { get; set; }
        public string TraceId { get; set; } = string.Empty;
        public Dictionary<string, List<string>> Errors { get; set; } = new();
    }
}