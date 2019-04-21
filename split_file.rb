require 'date'
File.foreach("./football").with_index do |line, line_num|
  next if line_num == 0
  query, date = line.split("\t")
  date = DateTime.parse(date)
  time = date.strftime("%H:%M:%S")
  filename = date.strftime("%W_%Y")
  datename = date.strftime("%d-%m-%Y")
  daily_file = File.open(filename + ".csv", "a+")
  daily_file.puts([query, datename, time].join(","))
  daily_file.close
end
