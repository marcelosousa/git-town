Feature: append a new feature branch to an existing feature branch

  Background:
    Given my repo has a feature branch "existing-feature"
    And my repo contains the commits
      | BRANCH           | LOCATION      | MESSAGE                 |
      | existing-feature | local, remote | existing_feature_commit |
    And I am on the "existing-feature" branch
    And my workspace has an uncommitted file
    When I run "git-town append new-child"

  Scenario: result
    Then it runs the commands
      | BRANCH           | COMMAND                                     |
      | existing-feature | git fetch --prune --tags                    |
      |                  | git add -A                                  |
      |                  | git stash                                   |
      |                  | git checkout main                           |
      | main             | git rebase origin/main                      |
      |                  | git checkout existing-feature               |
      | existing-feature | git merge --no-edit origin/existing-feature |
      |                  | git merge --no-edit main                    |
      |                  | git branch new-child existing-feature       |
      |                  | git checkout new-child                      |
      | new-child        | git stash pop                               |
    And I am now on the "new-child" branch
    And my workspace still contains my uncommitted file
    And my repo now has the commits
      | BRANCH           | LOCATION      | MESSAGE                 |
      | existing-feature | local, remote | existing_feature_commit |
      | new-child        | local         | existing_feature_commit |
    And Git Town is now aware of this branch hierarchy
      | BRANCH           | PARENT           |
      | existing-feature | main             |
      | new-child        | existing-feature |

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH           | COMMAND                       |
      | new-child        | git add -A                    |
      |                  | git stash                     |
      |                  | git checkout existing-feature |
      | existing-feature | git branch -D new-child       |
      |                  | git checkout main             |
      | main             | git checkout existing-feature |
      | existing-feature | git stash pop                 |
    And I am now on the "existing-feature" branch
    And my workspace still contains my uncommitted file
    And my repo is left with my original commits
    And Git Town still has the original branch hierarchy
