Feature: preserve the previous Git branch

  Background:
    Given my repo has the feature branches "previous" and "current"

  Scenario: current branch deleted, previous branch exists
    Given I am on the "current" branch with "previous" as the previous Git branch
    And the "current" branch gets deleted on the remote
    When I run "git-town prune-branches"
    Then I am now on the "main" branch
    And the previous Git branch is still "previous"

  Scenario: current branch exists, previous branch deleted
    Given the "previous" branch gets deleted on the remote
    And I am on the "current" branch with "previous" as the previous Git branch
    When I run "git-town prune-branches"
    Then I am still on the "current" branch
    And the previous Git branch is now "main"

  Scenario: both branches deleted
    Given I am on the "current" branch with "previous" as the previous Git branch
    And the "previous" branch gets deleted on the remote
    And the "current" branch gets deleted on the remote
    When I run "git-town prune-branches"
    Then I am now on the "main" branch
    And the previous Git branch is now "main"

  Scenario: both branches exist
    Given I am on the "current" branch with "previous" as the previous Git branch
    When I run "git-town prune-branches"
    Then I am still on the "current" branch
    And the previous Git branch is still "previous"
