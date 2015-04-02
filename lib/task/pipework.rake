namespace :pipework do
  desc 'install pipework (SDN)'
  task :install do
    Dir.chdir('/var/tmp') do
      sh "git clone https://github.com/jpetazzo/pipework" unless Dir.exists? 'pipework'
      sh "sudo cp /var/tmp/pipework/pipework /usr/local/bin"
      sh "sudo apt install -y udhcpc"
    end
  end
end
