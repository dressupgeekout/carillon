require 'sequel'

desc "Create the first user."
task :bootstrap do
  print "Pick a username: "
  username = STDIN.gets.chomp

  print "Pick a password: "
  `stty -echo`
  password = STDIN.gets.chomp
  `stty echo`
  puts

  DB = Sequel.sqlite File.join(File.dirname(__FILE__), 'db', 'carillon.sqlite3')
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
end
