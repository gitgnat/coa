namespace :consul do
  desc "forward bind port (udo) to localhost"
  task :forward_bind do
    sh "sudo iptables -A PREROUTING -t nat -i lo -p udp --dport 53 -j DNAT --to 192.168.16.5:8600"
    sh "sudo iptables -A FORWARD -p udp -d 192.168.16.5 --dport 8600 -j ACCEPT"
  end

  desc "install consul"
  task :install do
    urls = %w(https://dl.bintray.com/mitchellh/consul/0.3.1_linux_amd64.zip hconntrack -D -p udp -d 192.168.0.1 --dport=55555ttps://dl.bintray.com/mitchellh/consul/0.3.1_web_ui.zip)
    Dir.chdir('/var/tmp') do
      urls.each do |url|
        sh "wget #{url}"
        sh "unzip #{url.split('/').last}"
      end
    end
    sh "sudo apt-get update -y"
    sh "sudo apt-get install -y conntrack"
  end
end
