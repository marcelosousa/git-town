package cmd

import (
	"github.com/git-town/git-town/v7/src/cli"
	"github.com/git-town/git-town/v7/src/git"
	"github.com/git-town/git-town/v7/src/hosting"
	"github.com/git-town/git-town/v7/src/runstate"
	"github.com/git-town/git-town/v7/src/steps"
	"github.com/git-town/git-town/v7/src/userinput"
	"github.com/spf13/cobra"
)

type newPullRequestConfig struct {
	BranchesToSync []string
	InitialBranch  string
}

var newPullRequestCommand = &cobra.Command{
	Use:   "new-pull-request",
	Short: "Creates a new pull request",
	Long: `Creates a new pull request

Syncs the current branch
and opens a browser window to the new pull request page of your repository.

The form is pre-populated for the current branch
so that the pull request only shows the changes made
against the immediate parent branch.

Supported only for repositories hosted on GitHub, GitLab, Gitea and Bitbucket.
When using self-hosted versions this command needs to be configured with
"git config git-town.code-hosting-driver <driver>"
where driver is "github", "gitlab", "gitea", or "bitbucket".
When using SSH identities, this command needs to be configured with
"git config git-town.code-hosting-origin-hostname <hostname>"
where hostname matches what is in your ssh config file.`,
	Run: func(cmd *cobra.Command, args []string) {
		config, err := createNewPullRequestConfig(prodRepo)
		if err != nil {
			cli.Exit(err)
		}
		driver := hosting.NewDriver(&prodRepo.Config, &prodRepo.Silent, cli.PrintDriverAction)
		if driver == nil {
			cli.Exit(hosting.UnsupportedServiceError())
		}
		stepList, err := createNewPullRequestStepList(config, prodRepo)
		if err != nil {
			cli.Exit(err)
		}
		runState := runstate.New("new-pull-request", stepList)
		err = runstate.Execute(runState, prodRepo, driver)
		if err != nil {
			cli.Exit(err)
		}
	},
	Args: cobra.NoArgs,
	PreRunE: func(cmd *cobra.Command, args []string) error {
		if err := ValidateIsRepository(prodRepo); err != nil {
			return err
		}
		if err := validateIsConfigured(prodRepo); err != nil {
			return err
		}
		if err := prodRepo.Config.ValidateIsOnline(); err != nil {
			return err
		}
		return nil
	},
}

func createNewPullRequestConfig(repo *git.ProdRepo) (result newPullRequestConfig, err error) {
	hasOrigin, err := repo.Silent.HasRemote("origin")
	if err != nil {
		return result, err
	}
	if hasOrigin {
		err := repo.Logging.Fetch()
		if err != nil {
			return result, err
		}
	}
	result.InitialBranch, err = repo.Silent.CurrentBranch()
	if err != nil {
		return result, err
	}
	err = userinput.EnsureKnowsParentBranches([]string{result.InitialBranch}, repo)
	if err != nil {
		return result, err
	}
	result.BranchesToSync = append(repo.Config.AncestorBranches(result.InitialBranch), result.InitialBranch)
	return
}

func createNewPullRequestStepList(config newPullRequestConfig, repo *git.ProdRepo) (result runstate.StepList, err error) {
	for _, branchName := range config.BranchesToSync {
		steps, err := runstate.SyncBranchSteps(branchName, true, repo)
		if err != nil {
			return result, err
		}
		result.AppendList(steps)
	}
	err = result.Wrap(runstate.WrapOptions{RunInGitRoot: true, StashOpenChanges: true}, repo)
	if err != nil {
		return result, err
	}
	result.Append(&steps.CreatePullRequestStep{BranchName: config.InitialBranch})
	return result, nil
}

func init() {
	RootCmd.AddCommand(newPullRequestCommand)
}
