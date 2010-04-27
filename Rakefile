require 'sequel'

task :default => [:bootstrap]

desc "Create the first user."
task :bootstrap do
  print "Pick a username: "
  username = STDIN.gets.chomp

  print "Enter a password: "
  `stty -echo`
  password_a = STDIN.gets.chomp
  `stty echo`
  puts
  
  print "Enter the password (again): "
  `stty -echo`
  password_b = STDIN.gets.chomp
  `stty echo`
  puts
  
  if password_a == password_b and password_a.any? and password_b.any?
    DB = Sequel.sqlite File.join(File.dirname(__FILE__), 'db', 
                                 'carillon.sqlite3')
    DB.create_table?(:users) do
      primary_key :id
      text        :username
      text        :password
    end
    DB[:users].insert(
      :username => username,
      :password => password
    )
    puts "Successfully added #{username} to users."
  else
    puts "The passwords don't match. Try again."
  end
end
