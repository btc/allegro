#!/usr/bin/env ruby

require 'dotenv'
require 'git'
require 'octokit'
require 'optparse'
require 'tty-table'

DEFAULT_PADDING = [0, 1]
NUM_COMMITS_BACK = 100000000

def truncate(string, max)
  string.length > max ? "#{string[0...max]}..." : string
end

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

  default_end = Time.now
  one_week = 7*24*60*60
  default_start = default_end - one_week

  to = if options[:to].nil? then default_end else options[:to] end
  from = if options[:from].nil? then default_start else options[:from] end

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
  prs = prs.keep_if { |pr| pr.created_at > from }
  prs = prs.sort_by do |pr|
    [pr.user.login, 0 - pr.number.to_i]
  end

  table = TTY::Table.new header: ['user', 'PR', 'title', 'closed at']
  prs.each { |pr| table << [pr.user.login, pr.number, pr.title, pr.closed_at.localtime] }
  puts table.render(:unicode, padding: DEFAULT_PADDING)
  puts "\n"

  from = from.to_s
  to = to.to_s

  committers.each do |author|

    name = author.name
    email = author.email

    msgs = git.log(NUM_COMMITS_BACK).author(email).since(from).until(to).map do |commit|
      line1 = if commit.message.include?("\n") then commit.message[/(.*)\n/, 0] else commit.message end
      { sha: commit.sha, message: truncate(line1, 80), date: commit.date }
    end

    if msgs.empty?
      next
    end

    puts "=" * (name.length + " <>".length + email.length)
    puts "#{name} <#{email}>"
    puts "=" * (name.length + " <>".length + email.length)
    puts "\n"


    table = TTY::Table.new header: ['sha', 'message', 'commited at']
    msgs.sort_by { |h| h[:message] }.each do |h|
      table << [h[:sha][0..6], h[:message], h[:date].localtime]
    end
    puts table.render(:unicode, padding: DEFAULT_PADDING)

    file_changes = get_file_changes(repo: git, email: email, from: from, until: to)
    sorted_file_changes = file_changes.sort_by { |k,v| k }

    total_insertions = 0
    total_deletions = 0
    file_changes.each do |_, changes|
      total_insertions += changes[:insertions]
      total_deletions += changes[:deletions]
    end
    puts "\n"
    puts "+#{total_insertions}\t -#{total_deletions}"

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

