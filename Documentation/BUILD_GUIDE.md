## Default web3swift build:

1. Install carthage:
```
$ brew install carthage
```
2. Run carthage update:
``` 
$ carthage update --platform iOS
# Available platforms: `iOS, macOS`
```
3.  Build project in XCode:
Command + B 

## Build web3swift into .framework:
```
$ carthage build --no-skip-current --platform iOS
```
