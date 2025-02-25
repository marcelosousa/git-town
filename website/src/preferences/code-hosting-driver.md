# code-hosting-driver

```
git-town.code-hosting-driver=<github|gitlab|bitbucket|gitea>
```

To talk to the API of your code hosting service, Git Town needs to know which
code hosting service (GitHub, Gitlab, Bitbucket, etc) you use. Git Town can
automatically figure out the code hosting driver by looking at the URL of the
`origin` remote. In cases where that's not successful, for example when using
private instances of code hosting services, you can tell Git Town which code
hosting service you use via the _code-hosting-driver_ preference.

To set it, run `git config git-town.code-hosting-driver <driver>` where driver
is one of `github`, `gitlab`, `gitea`, or `bitbucket`.
