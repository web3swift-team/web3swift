# Contribution guide
## Version convention
We’re conforming [default versions convention](https://semver.org/).
So in the `1.0.0` version each position means follow:
- 1.\*.* — **major release**, includes API groundbreaking changes (ie: your old code will not work).
- \*.1.* — **minor release**, we’ve added some new feature to the lib, but we didn’t break something in anyway (ie: everything will work as expected without any moves after update).
- \*.*.1 — **patch release**, we’re haven’t add any breaking changes or even new features for the user, but we’ve fixed some bugs or rewrote something internal (ie: you should not event mention that anything were changed in the lib).

This library yet living within **three weeks minor release** schedule. Also please keep in mind that in sake of avoiding complex merge conflicts, we’re currently taking only **one big feature** in release, so if you want to take some, please drop us a message somewhere to avoiding reworking it after it’ll be broken by some massive merge.

Critical bug fixes are should be marked with appropriate label in PR and should be proceed **within one week** till patch ’ll be released (at least we’ll try our best to made that).

## What task to choose
Please take it from the [roadmap](https://hackmd.io/G5znP3xAQY-BVc1X8Y1jSg) or from the [opened issues](https://github.com/skywinder/web3swift/issues?q=is:issue+is:open+sort:updated-desc "").

> If you want to make something completely new and purely magical, please drop us a message somewhere before, since it could ends up that this is what we planning to do a lot later or that we not planning at all.

## Codestyle guideline
- `swiftlint` check should goes with no warnings.
- Here’s some more detailed and human readable code style [guidelines](https://hackmd.io/8bACoAnTSsKc55Os596yCg "") (you can add there some suggestion if you’d like to).
- We use [swift](https://www.swift.org/documentation/api-design-guidelines/ "") name convention.
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
- [ ] All new functionality covered by unit tests.
- [ ] Ci/cd green.
- [ ] No redundant files are added (build cache, Xcode breakpoints settings and so on).

### Info
- [ ] Relative and concrete PR title.
- [ ] Issue or roadmap goal attached.
- [ ] PR description filled with detail explanation of what it is and what’s its specific.

### Codestyle
- [ ] All public method have `///` styled comments.
- [ ] All magic or nonintuitive internal code parts are clearly explained in inline comments.
- [ ] `swiftlint` ran have no warnings.
- [ ] No commented out code lefts in PR.
