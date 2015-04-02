namespace :db do
  DB_HOSTNAME = 'db.service.dev0.consul'
  DB_IP = "dig @192.168.16.5 -p 8600 +short #{DB_HOSTNAME}"

  desc "cli"
  task :sql, [:sql] do |t,arg|
    ip = `#{DB_IP}`.strip
    cs = [] << 'psql'
    cs << "--host=#{ip}"
    cs << '--username=edu'
    cs << '--echo-all'
    cs << "--command='#{arg.sql}'" unless arg.sql.nil? || arg.sql == ''
    exec cs.join(' ')
  end

  desc "describe a table"
  task :desc, [:table] do |t,arg|
    sh "rake db:sql['\\\\d #{arg.table}'] PAGER=cat"
  end

  desc "truncate a table"
  task :trunc, [:table] do |t,arg|
    sh "rake db:sql['truncate #{arg.table}'] PAGER=cat"
  end

  desc "count all rows in a table"
  task :count, [:table] do |t,arg|
    sh "rake db:sql['select count(*) from #{arg.table}'] PAGER=cat"
  end

  desc "app. level reset db: drop, create, migrate"
  task :app_reset do
    sh "rake db:drop db:create db:migrate"
  end

  desc "stat db"
  task :start do
    sh "rake app:start[edu,postgres]"
  end
  
  desc "echo dot pgpass config"
  task :pgpass_info do
    ip = `#{DB_IP}`.strip
    puts "echo '#{ip}:5432:edu:edu:<PASSWORD>' > ~/.pgpass".yellow
    puts "chmod go-rwx ~/.pgpass".yellow
  end
  
  desc "db info"
  task :info do
    ip = `#{DB_IP}`.strip
    ["DB: " + "edu@#{ip}/edu".green, " ", "(#{DB_HOSTNAME})".yellow, "\n"].each do |s|
      print s
    end
    sh "rake db:version"
  end
end
