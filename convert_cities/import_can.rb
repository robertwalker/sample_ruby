require 'csv'

def convert
  in_file = "cc-full.txt"
  out_file = File.new("pzd.txt", "w")

  # Write header row
  # City State Zip County SPLC Country Placeholder
  out_file << "City\tState\tZip\tCounty\tSPLC\tCountry\tPlaceholder\n"
  
  reader = CSV.open(in_file, "r")
  i = 0
  reader.each do |row|
    city = row[2]
    state = row[1]
    zip = row[0].gsub(/ /, "")
    county = ""
    splc = ""
    country = "CAN"
    ph = "X"
    out_file << "#{city}\t#{state}\t#{zip}\t#{county}\t#{splc}\t#{country}\tX\n"
    i += 1
    puts "Processed: #{i}" if i % 1000 == 0
  end
  out_file.close
  i
end

row_count = convert
puts "Complete: #{row_count} rows processed"
