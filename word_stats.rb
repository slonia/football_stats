require 'csv'

filename = ARGV[0]
frequency = Hash.new(0)
words_to_exclude = ["чм", "2018", "июня", "июля"]
total_count = 0
CSV.foreach(filename) do |input|
  words = input[0].split(' ')
  words.each do |word|
    if word.size > 3 && !words_to_exclude.include?(word)
      frequency[word.downcase] += 1
      total_count += 1
    end
  end
end

CSV.open("stats_" + filename, "w") do |csv|
  csv << ['word', 'count', 'percentage']
  frequency.sort_by {|k, v| v}.last(100).reverse.each do |row|
    percentage = (row[1].to_f/total_count*100.0).round(2)
    csv << (row + [percentage])
  end
end
