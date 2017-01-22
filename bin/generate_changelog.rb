#!/usr/bin/env ruby

require 'logger'
require 'optparse'
require 'git'


def get_file_changes(h)
  email = h[:email]
  from = h[:from]
  to = h[:to]
  git = h[:repo]
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
  file_changes
end


if __FILE__ == $0
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ./generate_changelog.rb [options]"

    opts.on("-f", "--from DATE", "Start Date") { |v| options[:from] = v }
    opts.on("-t", "--to DATE", "End Date (Inclusive)") { |v| options[:to] = v }
  end.parse!

  from = if options[:from].nil? then "7 days" else options[:from] end
  to = if options[:to].nil? then "today" else options[:to] end

  git = Git.open(".")

  committers = git.log.since(from).until(to)
    .map { |commit| commit.author }
    .reduce([]) do |acc, author|

    # keep unique authors (by email)

    ret = acc + [author]
    for existing in acc do
      if existing.email == author.email
        ret = acc
      end
    end
    ret
  end

  committers.each do |author|

    name = author.name
    email = author.email

    puts "=" * (name.length + " <>".length + email.length)
    puts "#{name} <#{email}>"
    puts "=" * (name.length + " <>".length + email.length)
    puts "\n"

    msgs = git.log.author(email).since(from).until(to).map do |commit|
      if commit.message.include?("\n") then commit.message[/(.*)\n/, 0] else commit.message end
    end

    msgs.sort.each do |m|
      puts "* #{m}"
    end

    file_changes = get_file_changes(repo: git, email: email, from: from, until: to)
    sorted_file_changes = file_changes.sort_by { |k,v| k }

    puts "\n"
    sorted_file_changes.each do |pair|
      file_name = pair[0]
      changes = pair[1]
      puts "+#{changes[:insertions]}\t -#{changes[:deletions]}\t #{file_name}"
    end

    puts "\n"
    puts "\n"
  end
end
