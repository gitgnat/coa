namespace :macvlan do
  def ifaces
    `ip link show up`.each_line{|l|l.strip}.split("\n").select{|l|!!(l=~/^[0-9]+:/)}.map{|l|l.split[1].chomp(':')}
  end
  def guess_phy_iface
    # take first one
    ifaces.select{|i|!(i=~/^(lo|docker[0-9]+|lxcbr[0-9])$/)}[0]
  end

  GIFACE = guess_phy_iface
  IFACE = ENV['HW_IFACE'] || GIFACE
  MACVLAN = 'macvlan'
  VDEVICE = "#{MACVLAN}0"
  IP = `ip address show dev #{IFACE}|grep "inet "|awk '{print $2}'`.strip
  NETWORK = `ip -o route | grep #{IFACE}|grep -v default|awk '{print $1}'`.strip
  GATEWAY = `ip -o route | grep default|awk '{print $3}'`.strip

  desc "start macvlan on your host"
  task :start, [:iface,:force] do |t,arg|
    arg.with_defaults(iface:IFACE,force:'')
    wait_for_network unless arg.force == "f"
    puts "IP = #{IP}".cyan
    puts "NETWRK = #{NETWORK}".cyan
    puts "GATEWAY = #{GATEWAY}".cyan
    cs = host_guest_network(arg.iface)
    cs.each{|c|sh "sudo #{c}"}
  end

  desc "stop macvlan from your host"
  task :stop do
  end

  task :info do
    puts "IFACE = #{IFACE}"
    puts "IP = #{IP}"
    puts "NETWORK = #{NETWORK}"
    puts "GATEWAY = #{GATEWAY}"  
  end

  HOST = 'google.com'
  def wait_for_network
    # @todo: no coupling between IFACE and test (ping)
    while !system("ping -q -c 1 #{HOST} >/dev/null 2>&1") do
      puts 'waiting for your network ...'
      sleep 2
    end
  end

  def host_guest_network(iface)
    # http://www.furorteutonicus.eu/2013/08/04/enabling-host-guest-networking-with-kvm-macvlan-and-macvtap/
    cs = []
    cs << "ip link add link #{iface} #{VDEVICE} type #{MACVLAN} mode bridge"
    cs << "ip address add #{IP} dev #{VDEVICE}"
    cs << "ip link set dev #{VDEVICE} up"
    # routing table
    cs << "ip route flush dev #{iface}"
    cs << "ip route flush dev #{VDEVICE}"
    # add routes
    cs << "ip route add #{NETWORK} dev #{VDEVICE} metric 0"
    # add the default gateway
    cs << "ip route add default via #{GATEWAY}"
    cs
  end

  def host_guest_netw(iface)
    cs = [] 
    cs << "ip addr del #{IP} dev #{iface}"
    cs << "ip link add link #{iface} dev #{iface}m type macvlan mode bridge"
    cs << "ip link set #{iface}m up"
    cs << "ip addr add #{IP} dev #{iface}m"
    cs
  end
end
