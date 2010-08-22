#!/usr/bin/env ruby
require 'fileutils'

# Defaults for this server.
shell = "/bin/bash"
log_folder = "/root/bin"
home_folder = "/home"
sites_available_folder = "/etc/httpd/sites-available"
sites_enabled_folder = "/etc/httpd/sites-enabled"

# Get the current date and time.
now = Time.new.strftime("%Y-%m-%d %H:%M:%S")

# Check if you are root.
# if (Process.euid != 0)
#   puts "You must be root to run this command."
#   Process.exit
# end

# Define commands to be run.
useradd_cmd = "useradd"
passwd_cmd = "passwd"
apache_cmd = "/etc/init.d/httpd"

# Check that all commands exist.
commands = [useradd_cmd, passwd_cmd, apache_cmd]
# commands.each do |com|
#   if (!system("which -s " + com))
#     puts "The command \"" + com + "\" was not found on this system."
#     Process.exit
#   end
# end

# Get the IP address.
puts "IP address for the site?"
STDOUT.flush
ip = gets.chomp

# Validate the IP Address.
if ((ip =~ /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/) == nil)
  puts "Invalid IP address was entered."
  Process.exit
end

# Get the domain name.
puts "What is the domain name for the site? ex: www.example.com"
STDOUT.flush
domain = gets.downcase.chomp

# Validate the domain.
if ((domain =~ /^[-a-z0-9\.]+\.[a-z]{2,4}$/) == nil)
  puts "Invalid domain name was entered."
  Process.exit
end

# Determine if base domain should redirect to this domain.
domain_parts = domain.split(".")
base_domain = domain_parts[domain_parts.length - 2]
base_domain += "." + domain_parts[domain_parts.length - 1]
if (domain_parts.length == 3 && domain_parts[0] == "www")
  puts "Should the base domain \"" + base_domain + "\" redirect to this domain? [y|n]"
  STDOUT.flush
  redirect_answer = gets.downcase.chomp
  if (redirect_answer == "y" || redirect_answer ==  "yes")
    base_domain_redirect = true;
  else
    base_domain_redirect = false;
  end
else
  base_domain_redirect = false;
end

# Get the login
puts "What is the login for the site?"
STDOUT.flush
login = gets.downcase.chomp

# Validate the login.
if ((login =~ /^[a-z0-9]{3,16}$/) == nil)
  puts "Invalid login was entered."
  Process.exit
end
user_folder = "#{home_folder}/#{login}"

# Get the password
puts "What is the password for the site?"
STDOUT.flush
password = gets.chomp

# Validate the password
if ((password =~ /^[a-zA-Z0-9]{10,20}$/) == nil)
  puts "Invalid password was entered."
  Process.exit
end

# Create the user.
if (!system("useradd #{login} -d #{home_folder}/#{login} -m -c '#{domain}' -s #{shell} > #{log_folder}/create_site_output.log 2>&1"))
  puts "Failed to add the user to the server."
end

# Set the user password
if (!system("echo '#{password}' | passwd #{login} --stdin > #{log_folder}/create_site_output.log 2>&1"))
  puts "Failed to set the new user's password."
end

# Create user folders and set their ownership and permissions.
FileUtils.mkdir "#{user_folder}/cgi-bin"
FileUtils.mkdir "#{user_folder}/htdocs"
FileUtils.mkdir "#{user_folder}/logs"
FileUtils.chmod_R 0755, user_folder
FileUtils.chown_R login, login, user_folder
FileUtils.chown 'root', 'root', "#{user_folder}/logs"

# Create virtual host file.
File.open("#{sites_available_folder}/#{domain}", 'w') do |f|
  f.puts("### #{domain} ###")
  f.puts("<VirtualHost #{ip}:80>")
  f.puts("  ServerName #{domain}")
  f.puts("  ServerAdmin webmaster@#{base_domain}")
  f.puts("  DocumentRoot #{user_folder}/htdocs")
  f.puts("  ScriptAlias /cgi-bin/ #{user_folder}/cgi-bin/")
  f.puts("  CustomLog \"|/usr/local/sbin/cronolog #{user_folder}/logs/access-%Y%m%d.log\" combined")
  f.puts("  ErrorLog \"|/usr/local/sbin/cronolog #{user_folder}/logs/error-%Y%m%d.log\"")
  if (base_domain_redirect)
    f.puts("  RewriteEngine on")
    f.puts("  RewriteCond %{HTTP_HOST} ^#{}domain\.com")
    f.puts("  RewriteRule ^(.*)$ http://#{Regexp.escape(base_domain)}/$1 [R=permanent,L]")
  end
  f.puts("  <Directory #{user_folder}/htdocs>")
  f.puts("    Options +Includes +ExecCGI +SymLinksIfOwnerMatch")
  f.puts("  </Directory>")
  f.puts("</VirtualHost>")
end

# Link virtual host file into enabled folder.
if (!system("ln -s ../sites-available/#{domain} #{sites_enabled_folder}/#{domain} 2>&1"))
  puts "Failed link the virtual host into the sites enabled folder."
end

# Restart apache
if (!system("#{apache_cmd} graceful 2>&1"))
  puts "Failed restart apache."
end

# TODO: Output result.
puts "########## SITE DETAILS ##########"
puts "IP: #{ip}"
puts "Domain: #{domain}"
puts "Redirects traffic from #{base_domain}" if (base_domain_redirect)
puts "Login: #{login}"
puts "Password: #{password}"
puts "Shell: #{shell}"
puts "Home: #{user_folder}"

# TODO: Log new site.
# remove script out put log.