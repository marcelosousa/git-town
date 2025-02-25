Feature: in a local repo

  Background:
    Given my repo has a feature branch "existing-feature"
    And my repo does not have a remote origin
    And my repo contains the commits
      | BRANCH           | LOCATION | MESSAGE                 |
      | existing-feature | local    | existing_feature_commit |
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
    And my repo now has the commits
      | BRANCH           | LOCATION | MESSAGE                 |
      | existing-feature | local    | existing_feature_commit |
    And Git Town is now aware of this branch hierarchy
      | BRANCH           | PARENT |
      | existing-feature | main   |
      | new-feature      | main   |

  Scenario: undo
    When I run "git town undo"
    Then it runs the commands
      | BRANCH           | COMMAND                       |
      | new-feature      | git add -A                    |
      |                  | git stash                     |
      |                  | git checkout existing-feature |
      | existing-feature | git branch -d new-feature     |
      |                  | git stash pop                 |
    And I am now on the "existing-feature" branch
    And my repo is left with my original commits
    And my workspace still contains my uncommitted file
    And my repo now has its initial branches and branch hierarchy
