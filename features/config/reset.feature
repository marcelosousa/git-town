Feature: reset the configuration

  Scenario: with configuration
    Given the main branch is "main"
    And the perennial branches are "qa" and "staging"
    When I run "git-town config reset"
    Then Git Town is no longer configured for this repo

  Scenario: no configuration
    Given I haven't configured Git Town yet
    When I run "git-town config reset"
    Then Git Town is no longer configured for this repo
