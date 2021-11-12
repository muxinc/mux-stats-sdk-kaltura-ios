## How to release
1. Bump version in Mux-Stats-Kaltura.podspec
2. Bump version in XCode "General" for target: MUXSDKKaltura
3. Bump version in XCode "General" for target: MUXSDKKalturaTv
4. Push to your release branch in Github
5. Download artifact from the Build step of the [Buildkite pipeline](https://buildkite.com/mux/stats-sdk-kaltura-ios).
![Buildkite UI](https://user-images.githubusercontent.com/1444681/114637753-14089180-9c98-11eb-87df-05e894d066d9.png) Make sure this is from the latest commit on your branch. 
6. Unzip the file and copy the resulting `MUXSDKKaltura.xcframework` into `XCFramework`and commit this.
7. Github - Create a PR to check in all changed files.
8. If approved, squash & merge into main
9. Pull main locally and `git tag [YOUR NEW VERSION]` and `git push --tags`
10. Cocoapod - Run `pod spec lint` to local check pod validity
11. Cocoapod - Run `pod trunk push Mux-Stats-Kaltura.podspec`
12. Github UI - Make a new release with the new version. Attach the XCFramework artifacts from the automated build to the release.
13. Update the release notes in the [Kaltura Integration Guide](https://docs.mux.com/guides/data/monitor-kaltura-ios)

After release:

* Try the new version to the sample app in this repo.