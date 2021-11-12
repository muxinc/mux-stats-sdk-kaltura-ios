## How to release
1. Bump version in Mux-Stats-Kaltura.podspec
2. Bump version in XCode "General" for target: MUXSDKKaltura
3. Bump version in XCode "General" for target: MUXSDKKalturaTv
4. Push to your release branch in Github
5. Download artifact from the Build step of the [Buildkite pipeline](https://buildkite.com/mux/stats-sdk-kaltura-ios). ![Screen Shot 2021-11-12 at 15 07 55](https://user-images.githubusercontent.com/40036667/141535226-0e55767f-4660-4bfb-a6d5-306f9b2a8e46.png)
Make sure this is from the latest commit on your branch. 
7. Unzip the file and copy the resulting `MUXSDKKaltura.xcframework` into `XCFramework`and commit this.
8. Github - Create a PR to check in all changed files.
9. If approved, squash & merge into main
10. Pull main locally and `git tag [YOUR NEW VERSION]` and `git push --tags`
11. Cocoapod - Run `pod spec lint` to local check pod validity
12. Cocoapod - Run `pod trunk push Mux-Stats-Kaltura.podspec`
13. Github UI - Make a new release with the new version. Attach the XCFramework artifacts from the automated build to the release.
14. Update the release notes in the [Kaltura Integration Guide](https://docs.mux.com/guides/data/monitor-kaltura-ios)

After release:

* Try the new version to the sample app in this repo.
