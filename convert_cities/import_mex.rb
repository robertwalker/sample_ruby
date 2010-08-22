require 'csv'

def convert
  begin
  in_file = "mex-full-delim-english.txt"
  out_file = File.new("pzd.txt", "w")

  # Write header row
  # City State Zip County SPLC Country Placeholder
  out_file << "City\tState\tZip\tCounty\tSPLC\tCountry\tPlaceholder\n"
  
  reader = CSV.open(in_file, "r")
  header = reader.shift
  i = 0
  reader.each do |row|
    city = row[4]
    state = row[2]
    zip = row[0]
    county = row[5]
    splc = ""
    country = "MEX"
    ph = "X"
    out_file << "#{city}\t#{state}\t#{zip}\t#{county}\t#{splc}\t#{country}\tX\n"
    i += 1
      puts "Processed: #{i}" if i % 1000 == 0
  end
  out_file.close
  rescue
    puts "Failed on row #{i + 1}"
  end
  i
end

msg = convert
puts "Complete: #{msg} rows processed"
