#!/usr/bin/env ruby
require "rubygems"
require "redcloth"

# Define the directory where the script is located.
SCRIPTS_PATH = File.dirname(__FILE__)

# Requires exactly 1 argument, the name of the textile file to convert.
if (ARGV.length != 1) 
  puts "Usage: textile file_name.textile"
  exit 1
end

# Get the file name.
textile_file = ARGV[0]

# Check for its existance.
if (!File.exists? textile_file)
  puts "Error: \"" + textile_file + "\" does not exist.\n";
  exit 1
end

# Verify it's a textile file.
if (File.extname(textile_file).downcase != ".textile")
  puts "Error: \"" + textile_file + "\" is not a textile file.\n";
  exit 1
end

# Generate output file name.
output_file = textile_file.slice(0, textile_file.length - 8) + ".html"

# Convert textile file to html
File.open output_file, "w" do |f|
  # Write HTML header
  File.open(SCRIPTS_PATH + "/textile_assets/header.html", "r") { |h|
       f << h.read
  }
  
  # Write textile content
  File.open(textile_file, "r") { |t|
      f << RedCloth.new(t.read).to_html
  }
  
  # Write html footer
  File.open(SCRIPTS_PATH + "/textile_assets/footer.html", "r") { |ft|
      f << ft.read
  }
end

exit 0;