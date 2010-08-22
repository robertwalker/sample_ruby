require 'csv'
require 'parsedate'

def write_script
  sql_file = File.new("dormant.sql", "w")
  sql_file << "SET DEFINE ~\n"
  sql_file << "DELETE FROM GPS_UNIT_IMPORT;\n\n"

  reader = CSV.open("Trailer_List.csv", "r")
  header = reader.shift
  reader.each do |row|
    gps_provider_id = 1002
    trailer_number = row[1]
    last_location = row[2]
    event_time = parse_time(row[5])
    days_dormant = row[7].to_i
    external_power = (row[8] == "yes") ? 1 : 0
    latitude = row[9]
    longitude = row[10]
    position_late_changed_date = Time.now - (days_dormant * 24 * 60 * 60)
    unless trailer_number =~ /\d{10}/
      sql_file << "INSERT INTO GPS_UNIT_IMPORT " + 
                  "VALUES (#{gps_provider_id}, \'#{trailer_number}\', " +
                  "\'#{last_location}\', " +
                  event_time + ", " +
                  "#{days_dormant}, #{external_power}, \'#{latitude}\', \'#{longitude}\', " +
                  "\'" + position_late_changed_date.strftime("%d-%b-%y").upcase + "\'" + 
                  ");\n\n"
    end
  end
  sql_file << "COMMIT\n"
  sql_file.close
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
