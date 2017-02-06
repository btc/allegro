#!/usr/bin/env ruby

require 'chronic'
require 'dotenv'
require 'git'
require 'octokit'
require 'optparse'

NUM_COMMITS_BACK = 100000000

def get_file_changes(h)
  email = h[:email]
  from = h[:from]
  to = h[:to]
  git = h[:repo]
  file_changes = {}
  git.log(NUM_COMMITS_BACK).author(email).since(from).until(to).each do |commit|
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
  Dotenv.load
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ./generate_changelog.rb [options]"

    opts.on("-f", "--from DATE", "Start Date") { |v| options[:from] = v }
    opts.on("-t", "--to DATE", "End Date (Inclusive)") { |v| options[:to] = v }
  end.parse!

  from = if options[:from].nil? then "6 days ago" else options[:from] end
  to = if options[:to].nil? then "now" else options[:to] end

  git = Git.open(".")
  gh = Octokit::Client.new(access_token: ENV.fetch("GC_GH_TOKEN"))

  committers = git.log(NUM_COMMITS_BACK).since(from).until(to)
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

  team_name = "Team Allegro"
  puts "=" * team_name.length
  puts team_name
  puts "=" * team_name.length
  puts "\n"

  prs = gh.pulls "TeamAllegro/allegro", state: 'closed'
  prs = prs.keep_if { |pr| pr.created_at > Chronic.parse(from) }
  prs = prs.sort_by do |pr|
    [pr.user.login, 0 - pr.number.to_i]
  end

  prs.map { |pr| "#{pr.user.login}\t - ##{pr.number}\t - #{pr.title}" }.each { |m| puts m }
  puts "\n"

  committers.each do |author|

    name = author.name
    email = author.email

    puts "=" * (name.length + " <>".length + email.length)
    puts "#{name} <#{email}>"
    puts "=" * (name.length + " <>".length + email.length)
    puts "\n"

    msgs = git.log(NUM_COMMITS_BACK).author(email).since(from).until(to).map do |commit|
      line1 = if commit.message.include?("\n") then commit.message[/(.*)\n/, 0] else commit.message end
      { sha: commit.sha, message: line1 }
    end

    msgs.sort_by { |h| h[:message] }.each do |h|
      puts "#{h[:sha][0..6]} - #{h[:message]}"
    end

    file_changes = get_file_changes(repo: git, email: email, from: from, until: to)
    sorted_file_changes = file_changes.sort_by { |k,v| k }

    puts "\n"
    sorted_file_changes.each do |pair|
      file_name = pair[0]
      changes = pair[1]
      puts "+#{changes[:insertions]}\t -#{changes[:deletions]}\t #{file_name}"
    end

    total_insertions = 0
    total_deletions = 0
    file_changes.each do |_, changes|
      total_insertions += changes[:insertions]
      total_deletions += changes[:deletions]
    end
    puts "\n"
    puts "+#{total_insertions}\t -#{total_deletions}"

    puts "\n"
    puts "\n"
  end
end
