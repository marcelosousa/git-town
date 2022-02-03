Feature: local repo

  Background:
    Given my repo has a feature branch "existing-feature"
    And my repo does not have a remote origin
    And my repo contains the commits
      | BRANCH | LOCATION | MESSAGE     |
      | main   | local    | main commit |
    And I am on the "existing-feature" branch
    And my workspace has an uncommitted file
    When I run "git-town hack new-feature"

  Scenario: result
    Then it runs the commands
      | BRANCH           | COMMAND                     |
      | existing-feature | git add -A                  |
      |                  | git stash                   |
      |                  | git branch new-feature main |
      |                  | git checkout new-feature    |
      | new-feature      | git stash pop               |
    And I am now on the "new-feature" branch
    And my workspace still contains my uncommitted file
    And my repo now has the following commits
      | BRANCH      | LOCATION | MESSAGE     |
      | main        | local    | main commit |
      | new-feature | local    | main commit |
    And Git Town is now aware of this branch hierarchy
      | BRANCH           | PARENT |
      | existing-feature | main   |
      | new-feature      | main   |

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH           | COMMAND                       |
      | new-feature      | git add -A                    |
      |                  | git stash                     |
      |                  | git checkout existing-feature |
      | existing-feature | git branch -D new-feature     |
      |                  | git stash pop                 |
    And I am now on the "existing-feature" branch
    And my workspace still contains my uncommitted file
    And my repo is left with my original commits
    And Git Town is now aware of this branch hierarchy
      | BRANCH           | PARENT |
      | existing-feature | main   |
