Feature: sync inside a folder that doesn't exist on the main branch

  Background:
    Given my repo has the feature branches "current-feature" and "other-feature"
    And my repo contains the commits
      | BRANCH          | LOCATION      | MESSAGE                    | FILE NAME        | FILE CONTENT    |
      | main            | local, remote | conflicting main commit    | conflicting_file | main content    |
      | current-feature | local         | conflicting feature commit | conflicting_file | feature content |
      |                 |               | folder commit              | new_folder/file1 |                 |
      | other-feature   | local, remote | other feature commit       | file2            |                 |
    And I am on the "current-feature" branch
    And my workspace has an uncommitted file
    When I run "git-town sync --all" in the "new_folder" folder

  Scenario: result
    Then it runs the commands
      | BRANCH          | COMMAND                                    |
      | current-feature | git fetch --prune --tags                   |
      |                 | git add -A                                 |
      |                 | git stash                                  |
      |                 | git checkout main                          |
      | main            | git rebase origin/main                     |
      |                 | git checkout current-feature               |
      | current-feature | git merge --no-edit origin/current-feature |
      |                 | git merge --no-edit main                   |
    And I am still on the "current-feature" branch
    And my uncommitted file is stashed
    And my repo now has a merge in progress
    And it prints the error:
      """
      exit status 1
      """

  Scenario: abort
    When I run "git-town abort" in the "new_folder" folder
    Then it runs the commands
      | BRANCH          | COMMAND                      |
      | current-feature | git merge --abort            |
      |                 | git checkout main            |
      | main            | git checkout current-feature |
      | current-feature | git stash pop                |
    And I am still on the "current-feature" branch
    And my workspace has the uncommitted file again
    And there is no merge in progress
    And my repo is left with my original commits

  Scenario: continue without resolving the conflicts
    When I run "git-town continue" in the "new_folder" folder
    Then it runs no commands
    And it prints the error:
      """
      you must resolve the conflicts before continuing
      """
    And I am still on the "current-feature" branch
    And my uncommitted file is stashed
    And my repo still has a merge in progress

  Scenario: continue after resolving the conflicts
    When I resolve the conflict in "conflicting_file"
    And I run "git-town continue" in the "new_folder" folder
    Then it runs the commands
      | BRANCH          | COMMAND                                  |
      | current-feature | git commit --no-edit                     |
      |                 | git push                                 |
      |                 | git checkout other-feature               |
      | other-feature   | git merge --no-edit origin/other-feature |
      |                 | git merge --no-edit main                 |
      |                 | git push                                 |
      |                 | git checkout current-feature             |
      | current-feature | git push --tags                          |
      |                 | git stash pop                            |
    And I am still on the "current-feature" branch
    And my workspace has the uncommitted file again
    And there is no merge in progress
    And my repo now has the commits
      | BRANCH          | LOCATION      | MESSAGE                                  |
      | main            | local, remote | conflicting main commit                  |
      | current-feature | local, remote | conflicting feature commit               |
      |                 |               | folder commit                            |
      |                 |               | conflicting main commit                  |
      |                 |               | Merge branch 'main' into current-feature |
      | other-feature   | local, remote | other feature commit                     |
      |                 |               | conflicting main commit                  |
      |                 |               | Merge branch 'main' into other-feature   |
    And my repo still has these committed files
      | BRANCH          | NAME             | CONTENT          |
      | main            | conflicting_file | main content     |
      | current-feature | conflicting_file | resolved content |
      |                 | new_folder/file1 |                  |
      | other-feature   | conflicting_file | main content     |
      |                 | file2            |                  |
