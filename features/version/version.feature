Feature: show the version of the current Git Town installation

  Scenario: outside a Git repository
    Given my workspace is currently not a Git repo
    When I run "git-town version"
    Then it prints:
      """
      Git Town v0.0.0-dev
      """
