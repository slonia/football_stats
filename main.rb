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
countries = db.execute("select name from countries").flatten.map(&:downcase)
words = ["чм", "чемпионат мира", "футбол"]
country_words = ["матч", "июня", "июл", "2018", "трансляция", "счет", "счёт", "сборн"]

# Initial filter by general terms or country mention
terms_file = CSV.open("terms.csv", "w")
CSV.foreach("24_2018.csv") do |input|
  query = input[0].downcase
  if words.any? {|word| query.match(word) }
    terms_file << input
  elsif countries.any? {|country| query.match(country) }
    country = $~.to_s
    # 2nd filter for countries
    if country_words.any? {|w| query.match(w) } || (countries - [country]).any? {|c| query.match(c) }
      terms_file << input
    end
  end
end
terms_file.close

