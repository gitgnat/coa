namespace :net do
  desc "make a network:open-vswitch bridge =dev0"
  task :mk, [:name,:cidr] => :start do |t,arg|
    arg.with_defaults(name:DEVNET_NAME,cidr:DEVNET_CIDR)
    devnet = arg.name.nil? ? DEVNET_NAME : arg.name
    unless `sudo ovs-vsctl list-br`.split.map{|e|e.strip}.include? devnet
      sh "rake net:unmk[#{arg.name}] >/dev/null 2>&1 || exit 0"
      sh "sudo ovs-vsctl add-br #{devnet}"
    else
      puts "#{devnet}".green + " already exists:"
      `ip addr show #{devnet}|grep inet`.split("\n").map{|e|e.strip}.each{|ip|puts ip}
    end
    # two possible cases "inet" and "inet6"
    rs = `ip addr show #{devnet}|grep inet`.split("\n").map{|e|e.strip}.map{|e|e.split}.map{|e|e.first}
    unless rs.include? 'inet'
      sh "sudo ip addr add #{arg.cidr} dev #{devnet}" 
    end
  end
  task :make => :mk

  desc "unmk (unmake) a network:open-vswitch bridge =dev0"
  task :unmk, [:name] do |t,arg|
    devnet = arg.name.nil? ? DEVNET_NAME : arg.name
    sh "sudo ovs-vsctl del-br #{devnet}"
  end
  task :unmake => :unmk

  desc "remove all devices from ovs switch"
  task :clean, [:name] do |t,arg|
    arg.with_defaults(name: 'dev0')
    `sudo ovs-vsctl list-ports #{arg.name}`.split.each do |port|
      sh "sudo ovs-vsctl del-port #{port}"
    end
  end

  desc "remake/restart a network"
  task :rem => [:unmk, :mk]

  desc "list interfaces in dev net"
  task :ls, [:name] do |t,arg|
    arg.with_defaults(name:DEVNET_NAME)
    sh "sudo ovs-vsctl list-br"
    sh "sudo ovs-vsctl list-ports #{arg.name}"
  end
  task :list => :ls

  desc "rm (remove) a docker/lxc container to your dev net by name or id"
  task :rm, [:container,:name] do |t,arg|
    raise "container cannot be nil" unless arg.container.nil?
    arg.with_defaults(name:DEVNET_NAME) 
    sh "echo sudo ovs-vsctl del-port #{arg.name} <container to interface>"
  end

  desc "start a container, assign ip | dhcp, join \"name\" or default net"
  task :add, [:docker_image, :cidr_dhcp, :net_name, :opts, :debug] do |t,arg|
    raise "docker_image can't be nil" if arg.docker_image.nil?
    arg.with_defaults(cidr_dhcp: 'dhcp', net_name: DEVNET_NAME)
    docker_mk = Dokr.run(arg.docker_image, arg.opts, !arg.debug.nil?)
    p docker_mk.join ' '
    cid = `#{docker_mk.join ' '}`.strip
    sh "#{Dokr.net_add(arg.net_name, Dokr.hostname(cid), arg.cidr_dhcp).join ' '}"
  end

  # @todo: remove hacked spaghetti code amongst: net:join, #start, app:start--consolidate them
  desc "join a container (by name or id) to your dev net"
  task :join, [:cid, :cidr_dhcp, :net_name] do |t,arg|
    raise "cid (container id or name) can't be nil" if arg.cid.nil?
    arg.with_defaults(cidr_dhcp: 'dhcp', net_name: DEVNET_NAME)
    h = Dokr.hostname(arg.cid)
    puts "h=#{h}".red
    sh "#{Dokr.net_add(arg.net_name, Dokr.hostname(arg.cid), arg.cidr_dhcp).join ' '}"
  end

  desc "start openvswitch daemon"
  task :start do
    name = 'openvswitch-switch'
    if 'stop/waiting' == `/sbin/status #{name}`.strip.split.last
      sh "sudo start #{name}"
    end
  end

  desc "start openvswitch daemon"
  task :stop do
    name = 'openvswitch-switch'
    if 'start/running' == `/sbin/status #{name}`.strip.split.last
      sh "sudo stop #{name}", verbose: false
    end
  end
end
