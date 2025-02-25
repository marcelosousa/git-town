Feature: show help even if the current repo misses configuration

  Scenario Outline:
    Given I haven't configured Git Town yet
    When I run "<COMMAND>"
    Then it prints:
      """
      Usage:
        git-town [command]
      """

    Examples:
      | COMMAND       |
      | git-town      |
      | git-town help |
