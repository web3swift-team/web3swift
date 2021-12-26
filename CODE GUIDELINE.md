# Web3swift code guidelines
## General
* Git methodology — gitflow
* ci/cd must be ran successfully on every merge to develop
* commits description should be verbose and concrete.
    * at least each change in file should be described in several words.
    * No *etc* description allowed.
* Commit should not confusing by its size or content
    * If you’re adding or deleting a large amount of files you’ve should do it in separate commit, which will not include any code written by you.
    * If you’re renaming some type or do any other action that affects a large amount of source files do it as separate commit with such description `Rename ExampleType to AnotherExampleType`.
    * If you’re task is big enough, like, if it’s affecting 20+ source files where you’ll should to write your code, please, split it in separate commits that will affect less than 10 files at each. 

## CI/CD
CI/CD including follow checks:
- `swiftlint` with the ruleset which stores in `.swiftlint.yml` must produces no errors or warnings.
- compiling as library (on each supported platform)
    - Carthage
    - CocoaPods
    - Swift Package Manager 5.4
- compiling as dependency (on each supported platform)
    - Carthage
    - CocoaPods
    - Swift Package Manager 5.4
- All test should be green.

## General Code requirements
### Active development
- No rules for code quality applies while active development is going on.

### Merge to `develop`
- there’s shouldn’t have any commented out code in the library itself, but could be in Tests target.
- there’s should run CI/CD pipeline successfully.
- building the library should produce no warnings on both stages
    - no package manager warnings (Carthage, SPM, CocoaPods)
    - no target building warnings

## Swift code formatting requirements
### Active development
- No rules for code quality applies while active development is going on.

### Merge to `develop`
- if you’re not 100% sure that this is required there’s shouldn’t be any `#if DEBUG` clauses in the code.
- All required logs should be produced by `os_log()` method, not `print()` one.
    - all logs message should have clear descriptions.
- `try` clause should should be used to return optional value, not trows and error at most, that is could be called without `do { } catch { }` block. You’re able to use block above, but it should be required there, for example, there’s should be error handling code in `catch`.
- force optional try (`let someVar = try! someTrhowableMethod()`) are not allowed.
- there’s shouldn’t be any unsafe force unwrap (`let someVar = optionalVar!` at all. But you could use such case as `if !array.isEmpty, let element = array.first! { }`.
- All string types identifiers, like `if object.name == "someName" { }` should be strong typed as enum `if object.name = ExampleEnum.someName.rawValue`
- Newly added methods should be followed with its description by the Xcode builtin tools (`cmd+option+/`).
