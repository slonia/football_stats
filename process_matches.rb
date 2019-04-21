require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'sqlite3'
  gem 'pry'
end

require 'sqlite3'
require 'pry'
require 'date'
require 'csv'

db = SQLite3::Database.new "football.db"
matches = db.execute("select * from matches")

before_file = CSV.open("before_match.csv", "w")
in_match_file = CSV.open("during_match.csv", "w")
between_file = CSV.open("between_match.csv", "w")
after_file = CSV.open("after_match.csv", "w")

CSV.foreach("terms.csv") do |input|
  query_time = DateTime.parse("#{input[1]} #{input[2]}")
  matches_for_date = matches.select {|a| a[2] == query_time.strftime("%d.%m.%Y")}.sort_by {|s| s[2]}
  any_in_time = false
  any_between = false
  matches_for_date.each_with_index do |data, i|
    break if i == matches_for_date.size-1
    duration = if data[4].length > 8
      # "1 : 1 3 : 4" won by penalty
      # normal time + additional + penalty
      # 105 minutes + 30 minutes + 15 minutes
      150
    elsif data[4].length > 5
      # "2 : 1 ДВ" won in additional time
      # normal time + additional
      135
    else
      # normal time
      105
    end
    start_time = DateTime.parse("#{data[2]} #{data[3]}")
    end_time = start_time + Rational(duration, 60*24) # adding duration minutes
    in_time = query_time.between?(start_time, end_time)
    if in_time
      any_in_time = true
      break
    end
    next_match = matches_for_date[i+1]
    next_start_time = DateTime.parse("#{next_match[2]} #{next_match[3]}")
    between_time = query_time.between?(end_time, next_start_time)
    if between_time
      any_between = true
      break
    end
  end

  if any_in_time
    # in time
    in_match_file << input
  elsif any_between
    # between matches
    between_file << input
  elsif query_time < DateTime.parse("#{matches_for_date[0][2]} #{matches_for_date[0][3]}")
    # before first match
    before_file << input
  else
    # after last
    after_file << input
  end
end

before_file.close
in_match_file.close
between_file.close
after_file.close
