# git ship [branch name] [-m message]

The _ship_ command ("let's ship this feature") merges a completed feature branch
into the main branch and removes the feature branch. Before the merge it
[syncs](sync.md) the branch to be shipped. After the merge it pushes the main
branch to share the new commit on it with the rest of the world.

Git ship opens the default editor with a prepopulated commit message that you
can modify. You can submit an empty commit message to abort the shipping
process.

This command ships only direct children of the main branch. To ship a nested
feature branch, you need to first ship or [kill](kill.md) all its ancestor
branches.

### Variations

Similar to `git commit`, the `-m` parameter allows specifying the commit message
via the CLI.

If you use GitHub or Gitea, have enabled
[API access to your hosting provider](../quick-configuration.md#api-access-to-your-hosting-provider),
and the branch to be shipped has an open pull request, this command merges pull
requests via the API of the hosting service.

If your origin server deletes shipped branches, for example
[GitHub's feature to automatically delete head branches](https://help.github.com/en/github/administering-a-repository/managing-the-automatic-deletion-of-branches),
you can
[disable deleting remote branches](../preferences/ship-delete-remote-branch.md).
