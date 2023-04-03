# Contribution guide
## Version convention
We’re conforming [default versions convention](https://semver.org/).
So in the `1.0.0` version, each position means the following:
- 1.\*.* — **major release**. Includes breaking changes. As the result, your old code will break with the new version;
- \*.1.* — **minor release**. Added one or more new features to the lib and no breaking changes were introduced. Everything will work as expected, no changes are required in your projects;
- \*.*.1 — **patch release**. Fixed one or more bugs, performed code refactoring, updated documentation or did something with the existing code base that doesn’t include new features nor breaks current ones.

Though, this library is living within the **three weeks minor release** schedule, please keep in mind that for the sake of avoiding complex merge conflicts, we’re currently taking only **one big feature** per release, so if you want to take some, please drop us a message somewhere (e.g. in [Discord](https://discord.com/invite/8bHCNmhS7x) in #contributors channel) to avoiding reworking it after it’ll be broken by some massive merge and to plan it correctly before you start.

Critical bug fixes must be marked with the appropriate label in PR and should be processed **within one week** (at least we’ll try our best to make that).

## Choosing a task
Please take it from the [roadmap](https://hackmd.io/G5znP3xAQY-BVc1X8Y1jSg) or from the [opened issues](https://github.com/skywinder/web3swift/issues?q=is:issue+is:open+sort:updated-desc "").

> If you want to make something completely new and purely magical, please drop us a message somewhere before you start (e.g. in [Discord](https://discord.com/invite/8bHCNmhS7x) in #contributors channel). Some features could be already planned but for a later stages or not planned (purposefuly not willing to include) at all.

## Codestyle guideline
- `swiftlint` check should goes with no warnings.
- Here’s some more detailed and human readable code style [guidelines](https://hackmd.io/8bACoAnTSsKc55Os596yCg) (you can add there some suggestion if you’d like to).
- We use [swift](https://www.swift.org/documentation/api-design-guidelines/) name convention.

## Tests guideline
1. Cover each new public method with tests.
2. If you’re implementing some big feature encapsulate it in Separate file.
3. Choose one of the two directory to add test case:
	* `localTests` — tests which could be ran without needing to connecting to real Ethereum network.
	* `remoteTests` — tests which needing connection to real Ethereum network to be ran.
4. Exclude added file from opposite `*.xctestplan` file (e.g. if you’re adding file to `localTests` please exclude it from `RemoteTests.xctestplan`.
5. Add test file to `web3swift.xcodeproj` to make it working within Carthage building system.

## Hacks & tricks & magic
### TestPlans
In ci/cd we’re using Xcode test plans feature to spread tests to local and remote one. So any time you’re adding any new test suit (file) please exclude it from `LocalTests.xctestplan` rather `RemoteTests.xctestplan` depends on what tests group it included.

### Swift package manager
Please add any files unused due build process to `excludeFiles` array in `Package.swift`.

### Carthage
Please do not forget to add & remove all new or dropped files and dependencies in carthage `.xcodeproj` file if you’re working with project anywhere but carthage project.

### Cocoapods
Please do not forget to add & remove all dependencies within `web3swift.podspec` file.

### GitHub actions
You’re able to use our github actions checks in your fork without needing to make PR to this repo. To get that just add your branch name to the branch list in file on path `.github/actions/ci.yml` to let the magic happening like follow:

```yml
on:
  push:
    branches:
      - master
      - develop
      - hotfix
      - #YOUR_REPO_NAME#
```

> Please remove your branch from this list before making PR.

## Good PR checklist
### Code
- [ ] All new functionality is covered by unit tests;
- [ ] All changes are focused on something specific, e.g. 1 feature 1 PR, 1 file refactored in 1 PR (depends on how much was refactored, etc.);
- [ ] No redundant files are added (build cache, Xcode breakpoints settings and so on);
- [ ] Documentation is added or updated. Refactoring a function with no documentation - add documentation. Fixing a bug - updated documentation to reflect changes correctly.

### Info
- [ ] Short and understandable PR title;
- [ ] Issue or roadmap goal is attached if applicable;
- [ ] PR description filled with detailed explanation of what was changed and reasons for the changes made.

### Codestyle
- [ ] All public method have `///` styled comments;
- [ ] All magic or nonintuitive internal code parts are clearly explained with additional in inline comments;
- [ ] No commented out code is left in a PR.
