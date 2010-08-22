require 'csv'
require 'parsedate'

TABLE_NAME = "QC_TEXT_MESSAGES"
NO_DELIMITER = [4, 5, 8, 10, 12, 16, 21, 22]

def write_script
  sql_file = File.new("#{TABLE_NAME.downcase}.sql", "w")
  sql_file << "SET DEFINE OFF\n"
  sql_file << "DELETE FROM #{TABLE_NAME};\n\n"

  reader = CSV.open("#{TABLE_NAME}.csv", "r")
  header = reader.shift
  column_names = process(header, true)
  counter = 0
  reader.each do |row|
    values = process(row)
    sql_file <<  "INSERT INTO #{TABLE_NAME} #{column_names} VALUES #{values};\n\n"
    counter += 1
  end
  sql_file << "COMMIT\n"
  sql_file.close
  puts "#{counter} rows processed"
end

def process(row, skip_delimiter=false)
  values = "("
  row.each do |c|
    c = c.gsub(/\'/, "''")
    values << ", " if values.length > 1
    if c.length == 0
      values << "NULL"
    else
      values << ((skip_delimiter || NO_DELIMITER.include?(row.index(c))) ? c : "'#{c}'")
    end
  end
  values << ")"
end

def parse_time(value)
  if value != nil && value != ""
    d = ParseDate.parsedate(value)
    t = Time.local(*d)
    "\'" + t.strftime("%d-%b-%y %H:%M:%S").upcase + "\'"
  else
    "NULL"
  end
end

write_script
puts "Complete"
