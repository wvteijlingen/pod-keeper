# PodKeeper

Automated dependency management for CococaPods. PodKeeper is a small command line utility that scans
your project for outdated pods, and creates pull requests for any available upgrades.

## What does it do?

When you run PodKeeper, it will go through the following steps:

1. Checkout the latest version of your development branch.
2. Find all pods that are upgradable according to its version constraints.

For each available upgrade, it will then:

3. Create a separate branch.
4. Upgrade the pod in that branch.
5. Create a pull request to merge the branch back into your development branch.

## Usage

Run the following command in your project root:

```
podkeeper --branch <branch> --project <project id> --token <token>
```

Required options:
 - `--branch`: The branch that PodKeeper will checkout to scan your project. Usually you want this to be
 your most up to date development branch.
 - `--project`: The project ID of the project in GitLab.
 - `--token`: A GitLab private token that has access to the project.

Optional options:
 - `--dry`: When set, PodKeeper will do a dry run and indicate what will happen without making any actual changes.


### Run periodically

Instead of manually running PodKeeper, you might want to run it periodically using something like a cronjob.

## Platforms

PodKeeper currently only works with GitLab, but it is easy to extend it to GitHub.Feel free to contribute and create a PR for this.
