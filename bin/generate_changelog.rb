#!/usr/bin/env ruby

require 'logger'
require 'optparse'
require 'git'

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

  committers = git.log.since(from).until(to)
    .map { |commit| commit.author }
    .reduce([]) do |acc, author|
    ret = acc + [author]
    for existing in acc do
      if existing.email == author.email
        ret = acc
      end
    end
    ret
  end.flatten

  committers.each do |author|

    name = author.name
    email = author.email

    puts "=" * (name.length + " <>".length + email.length)
    puts "#{name} <#{email}>"
    puts "=" * (name.length + " <>".length + email.length)
    puts "\n"

    git.log.author(email).since(from).until(to).each do |commit|
      line1 = if commit.message.include?("\n") then commit.message[/(.*)\n/, 0] else commit.message end
      puts "* #{line1}"
    end

    file_changes = {}
    git.log.author(email).since(from).until(to).each do |commit|
      commit.diff_parent.stats[:files].each do |file_name, changes|
        existing_changes = file_changes[file_name]
        if existing_changes.nil?
          existing_changes = {
            insertions: 0,
            deletions: 0,
          }
        end
        # NB: changes are relative to parent, so we actually need to count
        # deletions as insertions and insertions as deletions
        file_changes[file_name] = {
          insertions: existing_changes[:insertions] + changes[:deletions],
          deletions: existing_changes[:deletions] + changes[:insertions],
        }
      end
    end

    puts "\n"
    file_changes.each do |file_name,  changes|
      puts "+#{changes[:insertions]}\t -#{changes[:deletions]}\t #{file_name}"
    end

    puts "\n"
    puts "\n"
  end
end
