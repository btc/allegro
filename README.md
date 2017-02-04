| `master` |
|:--------:|
| [![CircleCI](https://circleci.com/gh/TeamAllegro/allegro.svg?style=svg&circle-token=027c45e319de130d49216fe2fcc036eeb5a800f5)](https://circleci.com/gh/TeamAllegro/allegro) |

# Configuring Your Development Environment

1. Clone the repo
1. Run `bundle install` to install ruby gems
1. Run `bundle exec pod install` to install Cocoapods dependencies
1. Run `make deps` to install Carthage dependencies
1. Run `make match` to download the Development and AppStore Provisioning Profiles. You'll be prompted for a password. The password is farm.
1. Install Xcode 8 (for Swift 3)
1. Open `allegro.xcworkspace` in Xcode. macOS may attempt to woo you into opening `allegro.xcodeproj`. Resist. Because we use Cocoapods, we *must* use `allegro.xcworkspace`.

# Resources

[Install Bundler](http://bundler.io/)

[Install Cocoapods](https://guides.cocoapods.org/using/getting-started.html)

[Install Carthage](https://github.com/Carthage/Carthage#installing-carthage)

[Install Fastlane](https://github.com/fastlane/fastlane#installation)

[Awesome iOS](https://github.com/vsouza/awesome-ios)

[List of Musical Symbols](https://en.wikipedia.org/wiki/List_of_musical_symbols)

Swift Style Guides: [GitHub](https://github.com/github/swift-style-guide#only-explicitly-refer-to-self-when-required), [LinkedIn](https://github.com/linkedin/swift-style-guide)
