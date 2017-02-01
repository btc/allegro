changelog:
	bundle exec ruby bin/generate_changelog.rb

deps: carthage_bootstrap_intelligently

match: gems
	bundle exec fastlane match development --readonly
	bundle exec fastlane match appstore --readonly

carthage_bootstrap_intelligently: gems
	bundle exec ruby bin/carthage_bootstrap_intelligently.rb

gems:
	bundle install
