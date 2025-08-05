Feature: Card Owner Validation
  As a payment processing system
  I want to validate credit card owner names
  So that only valid owner names are accepted

  Background:
    Given the card validation service is available at "https://cardvalidation.api:7135/CardValidation/card/credit/validate"

  Scenario Outline: Valid owner names should be accepted
    Given I have a credit card with the following details:
      | Field  | Value             |
      | owner  | <ownerName>       |
      | number | 4111111111111111  |
      | date   | 12/2025           |
      | cvv    | 123               |
    When I send the validation request
    Then the response status code should be 200
    And the response should indicate payment system type "Visa"

    Examples:
      | ownerName        |
      | John             |
      | John Doe         |
      | John Doe Smith   |
      | Mary Jane Watson |
      | A B C            |

  Scenario Outline: Invalid owner names should return validation error
    Given I have a credit card with the following details:
      | Field  | Value             |
      | owner  | <ownerName>       |
      | number | 4111111111111111  |
      | date   | 12/2025           |
      | cvv    | 123               |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Wrong owner"

    Examples:
      | ownerName               |
      | John123                 |
      | John-Doe                |
      | John_Doe                |
      | John@Doe                |
      | John.Doe                |
      | John  Doe               |
      | John Doe Smith Jr       |
      | John Doe Smith Jr Brown |
      | 123                     |
      | @#$%                    |

  Scenario: Empty owner name should return required field error
    Given I have a credit card with the following details:
      | Field  | Value            |
      | owner  |                  |
      | number | 4111111111111111 |
      | date   | 12/2025          |
      | cvv    | 123              |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Owner is required"

  Scenario: Missing owner field should return required field error
    Given I have a credit card with the following details:
      | Field  | Value            |
      | number | 4111111111111111 |
      | date   | 12/2025          |
      | cvv    | 123              |
    When I send the validation request
    Then the response status code should be 400
    And the response should contain error message "Owner is required"