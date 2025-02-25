Feature: handle conflicts between the current perennial branch and its tracking branch

  Background:
    Given my repo has the perennial branches "production" and "qa"
    And my repo contains the commits
      | BRANCH | LOCATION | MESSAGE                   | FILE NAME        | FILE CONTENT               |
      | qa     | local    | conflicting local commit  | conflicting_file | local conflicting content  |
      |        | remote   | conflicting remote commit | conflicting_file | remote conflicting content |
    And I am on the "qa" branch
    And my workspace has an uncommitted file
    When I run "git-town sync"

  Scenario: result
    Then it runs the commands
      | BRANCH | COMMAND                  |
      | qa     | git fetch --prune --tags |
      |        | git add -A               |
      |        | git stash                |
      |        | git rebase origin/qa     |
    And it prints the error:
      """
      To abort, run "git-town abort".
      To continue after having resolved conflicts, run "git-town continue".
      To continue by skipping the current branch, run "git-town skip".
      """
    And my repo now has a rebase in progress
    And my uncommitted file is stashed

  Scenario: abort
    When I run "git-town abort"
    Then it runs the commands
      | BRANCH | COMMAND            |
      | qa     | git rebase --abort |
      |        | git stash pop      |
    And I am still on the "qa" branch
    And my workspace still contains my uncommitted file
    And there is no rebase in progress anymore
    And my repo is left with my original commits

  Scenario: continue without resolving the conflicts
    When I run "git-town continue"
    Then it runs no commands
    And it prints the error:
      """
      you must resolve the conflicts before continuing
      """
    And my uncommitted file is stashed
    And my repo still has a rebase in progress

  Scenario: continue after resolving the conflicts
    When I resolve the conflict in "conflicting_file"
    And I run "git-town continue" and close the editor
    Then it runs the commands
      | BRANCH | COMMAND               |
      | qa     | git rebase --continue |
      |        | git push              |
      |        | git push --tags       |
      |        | git stash pop         |
    And I am still on the "qa" branch
    And my workspace still contains my uncommitted file
    And all branches are now synchronized
    And my repo now has these committed files
      | BRANCH | NAME             | CONTENT          |
      | qa     | conflicting_file | resolved content |

  Scenario: continue after resolving the conflicts and continuing the rebase
    When I resolve the conflict in "conflicting_file"
    And I run "git rebase --continue" and close the editor
    And I run "git-town continue"
    Then it runs the commands
      | BRANCH | COMMAND         |
      | qa     | git push        |
      |        | git push --tags |
      |        | git stash pop   |
    And I am still on the "qa" branch
    And my workspace still contains my uncommitted file
    And all branches are now synchronized
    And my repo now has these committed files
      | BRANCH | NAME             | CONTENT          |
      | qa     | conflicting_file | resolved content |
