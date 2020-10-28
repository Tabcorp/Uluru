fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios do_release
```
fastlane ios do_release
```
Releases and publishes new version to github releases and podspec.

Before this step you should commit and push code
### ios release_dry_run
```
fastlane ios release_dry_run
```
Release dry run, all steps expect uploading release.
### ios lint_podspec
```
fastlane ios lint_podspec
```
Lint podspec
### ios prepare_build
```
fastlane ios prepare_build
```
Prepares build
### ios publish_podspec
```
fastlane ios publish_podspec
```
Prepares and publishes podspec

Uses git tag as the version number

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).