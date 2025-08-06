Feature: Card Date Validation
  As a payment processing system
  I want to validate credit card expiration dates
  So that only valid future dates are accepted

  Background:
    Given the card validation service is available at credit card validation url

  Scenario Outline: Valid future dates should be accepted
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  | John Doe         |
      | number | 4111111111111111 |
      | date   | <date>           |
      | cvv    | 123              |
    When I send the validation request
    Then the response status code should be 200
    And the response should indicate payment system type "Visa"

    Examples:
      | date     |
      | 12/2025  |
      | 01/2026  |
      | 12/25    |
      | 01/26    |
      | 06/2030  |
      | 12/30    |

  Scenario Outline: Invalid date formats should return validation error
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  | John Doe         |
      | number | 4111111111111111 |
      | date   | <date>           |
      | cvv    | 123              |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Wrong date"

    Examples:
      | date        |
      | 13/2025     |
      | 00/2025     |
      | 12/202      |
      | 12/20255    |
      | 2025/12     |
      | 12-2025     |
      | 12.2025     |
      | 12 2025     |
      | Dec/2025    |
      | 12/Dec      |
      | invalid     |
      | 1/2025      |
      | 12/5        |

  Scenario Outline: Past dates should return validation error
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  | John Doe         |
      | number | 4111111111111111 |
      | date   | <date>           |
      | cvv    | 123              |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Wrong date"

    Examples:
      | date     |
      | 01/2020  |
      | 12/2023  |
      | 06/20    |
      | 01/24    |

  Scenario: Empty date should return required field error
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  | John Doe         |
      | number | 4111111111111111 |
      | date   |                  |
      | cvv    | 123              |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Date is required"

  Scenario: Missing date field should return required field error
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  | John Doe         |
      | number | 4111111111111111 |
      | cvv    | 123              |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Date is required"