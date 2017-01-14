How to build the project:

1. Install Xcode 8 (for Swift 3)
1. Run `pod install` to install Cocoapods dependencies
1. Run `carthage bootstrap --no-use-binaries` to install Carthage dependencies
1. Run `fastlane match development --readonly` to download the iOS Provisioning Profile. You'll be prompted for a password. The password is farm.
1. Open `allegro.xcworkspace` in Xcode
1. Build!

You may find these links useful:

[Install Cocoapods](https://guides.cocoapods.org/using/getting-started.html)

[Install Carthage](https://github.com/Carthage/Carthage#installing-carthage)

[Install Fastlane](https://github.com/fastlane/fastlane#installation)

Cocoapods and Fastlane are both made with Ruby. If you are familiar with Ruby,
you can install the two gems using the provided Gemfile. To do so, run `bundle
install`. Afterward, instead of running `pod install`, you run `bundle exec pod
install`. The same goes for Fastlane. Prefix your command with `bundle exec`.
