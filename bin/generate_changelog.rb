#!/usr/bin/env ruby

require 'byebug'
require 'logger'
require 'optparse'
require 'git'

TEAM_MEMBERS = {
  "Brian Tiger Chow" => "brian.holderchow@gmail.com",
}

if __FILE__ == $0
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ./generate_changelog.rb [options]"

    opts.on("-f", "--from DATE", "Start Date") { |v| options[:from] = v }
    opts.on("-t", "--to DATE", "End Date (Inclusive)") { |v| options[:to] = v }
  end.parse!

  raise OptionParser::MissingArgument if options[:from].nil?
  raise OptionParser::MissingArgument if options[:to].nil?

  from = options[:from]
  to = options[:to]

  git = Git.open(".")

  TEAM_MEMBERS.each do |name, email|

    puts "=" * (name.length + " <>".length + email.length)
    puts "#{name} <#{email}>"
    puts "=" * (name.length + " <>".length + email.length)
    puts "\n"

    git.log.author(email).since(from).until(to).each do |commit|
      line1 = if commit.message.include?("\n") then commit.message[/(.*)\n/, 0] else commit.message end
      puts "* #{line1}"
    end

    puts "\n"
    puts "\n"
  end
end
