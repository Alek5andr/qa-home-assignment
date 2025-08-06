Feature: Card Number Validation
  As a payment processing system
  I want to validate credit card numbers
  So that only valid card numbers are accepted

  Background:
    Given the card validation service is available at credit card validation url

  Scenario Outline: Valid card numbers should return correct payment system type
    Given I have a credit card with the following details:
      | Field  | Value        |
      | owner  | John Doe     |
      | number | <cardNumber> |
      | date   | 12/2025      |
      | cvv    | 123          |
    When I send the validation request
    Then the response status code should be 200
    And the response should indicate payment system type "<paymentSystem>"

    Examples:
      | cardNumber          | paymentSystem   |
      | 4111111111111111    | Visa            |
      | 4000000000000002    | Visa            |
      | 5555555555554444    | MasterCard      |
      | 5105105105105100    | MasterCard      |
      | 2221000000000009    | MasterCard      |
      | 2720999999999996    | MasterCard      |
      | 371449635398431     | AmericanExpress |
      | 378282246310005     | AmericanExpress |

  Scenario Outline: Invalid card numbers should return validation error
    Given I have a credit card with the following details:
      | Field  | Value        |
      | owner  | John Doe     |
      | number | <cardNumber> |
      | date   | 12/2025      |
      | cvv    | 123          |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Wrong number"

    Examples:
      | cardNumber          |
      | 1234567890123456    |
      | 6011111111111117    |
      | 3530111333300000    |
      | 4111-1111-1111-1111 |
      | 411111111111111a    |
      | 41111111111111111   |

  Scenario: Empty card number should return required field error
    Given I have a credit card with the following details:
      | Field  | Value    |
      | owner  | John Doe |
      | number |          |
      | date   | 12/2025  |
      | cvv    | 123      |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Number is required"

  Scenario: Missing card number should return required field error
    Given I have a credit card with the following details:
      | Field | Value    |
      | owner | John Doe |
      | date  | 12/2025  |
      | cvv   | 123      |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Number is required"