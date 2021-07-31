## Build

### Default web3swift build:

1. Install carthage:
```
brew install carthage
```
2. Run carthage update:
```
# Available platforms: `iOS, macOS` 
carthage update --platform iOS --use-xcframeworks
```
3.  Build project in XCode:
`Command + B` 

### Build web3swift into .framework:
```
carthage build --no-skip-current --platform iOS
```
