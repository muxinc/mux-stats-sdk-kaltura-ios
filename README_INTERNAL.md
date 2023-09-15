## How to release
1. Bump version in Mux-Stats-Kaltura.podspec
2. Github - Create a PR to check in all changed files.
3. If approved, squash & merge into main
4. Pull main locally and `git tag [YOUR NEW VERSION]` and `git push --tags`
5. Cocoapod - Run `pod spec lint` to local check pod validity
6. Cocoapod - Run `pod trunk push Mux-Stats-Kaltura.podspec`
7. Github UI - Make a new release with the new version. Attach the XCFramework artifacts from the automated build to the release.
8. Update the release notes in the [Kaltura Integration Guide](https://docs.mux.com/guides/data/monitor-kaltura-ios)

Note:

Pushing to Cocoapods Trunk requires use of Xcode 14.2

After release:

* Try the new version to the sample app in this repo.
