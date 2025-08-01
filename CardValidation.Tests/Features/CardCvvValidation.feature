Feature: Card CVV Validation
  As a payment processing system
  I want to validate credit card CVV codes
  So that only valid CVV codes are accepted

  Background:
    Given the card validation service is available at "https://localhost:7135/CardValidation/card/credit/validate"

  Scenario Outline: Valid CVV codes should be accepted
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  | John Doe         |
      | number | <cardNumber>     |
      | date   | 12/2025          |
      | cvv    | <cvv>            |
    When I send the validation request
    Then the response status code should be 200
    And the response should indicate payment system type "<paymentSystem>"

    Examples:
      | cardNumber          | cvv  | paymentSystem   |
      | 4111111111111111    | 123  | Visa            |
      | 4111111111111111    | 999  | Visa            |
      | 4111111111111111    | 000  | Visa            |
      | 5555555555554444    | 456  | MasterCard      |
      | 5555555555554444    | 789  | MasterCard      |
      | 371449635398431     | 1234 | AmericanExpress |
      | 371449635398431     | 9999 | AmericanExpress |
      | 371449635398431     | 0000 | AmericanExpress |

  Scenario Outline: Invalid CVV codes should return validation error
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  | John Doe         |
      | number | 4111111111111111 |
      | date   | 12/2025          |
      | cvv    | <cvv>            |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Wrong cvv"

    Examples:
      | cvv    |
      | 12     |
      | 1      |
      | 12345  |
      | abc    |
      | 12a    |
      | 1a3    |
      | a23    |
      | 12-3   |
      | 12.3   |
      | 12 3   |

  Scenario: Empty CVV should return required field error
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  | John Doe         |
      | number | 4111111111111111 |
      | date   | 12/2025          |
      | cvv    |                  |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Cvv is required"

  Scenario: Missing CVV field should return required field error
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  | John Doe         |
      | number | 4111111111111111 |
      | date   | 12/2025          |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Cvv is required"