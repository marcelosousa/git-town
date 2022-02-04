Feature: preserve the previous Git branch

  Background:
    Given my repo has the feature branches "previous" and "current"
    And I am on the "current" branch with "previous" as the previous Git branch

  Scenario: previous branch exists
    When I run "git-town kill"
    Then I am now on the "main" branch
    And the previous Git branch is still "previous"

  Scenario: previous branch deleted
    When I run "git-town kill previous"
    Then I am still on the "current" branch
    And the previous Git branch is now "main"
