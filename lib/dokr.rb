module Dokr
  def Dokr.run(image, opts ='', debug =false)
    cmd = [] 
    cmd << 'docker'
    cmd << 'run'
    cmd << '--cap-add=NET_ADMIN'
    unless debug
      cmd << '--detach'
    else
      # also used for dev mode
      cmd << '--interactive=true'
      cmd << '--tty=true' 
      cmd << "--user=root"
      cmd << '--entrypoint=/bin/bash' 
    end
    cmd += opts.split(/\s+/) unless opts.nil? || opts == ''
    cmd << image
    cmd
  end

  def Dokr.net_add(net_name, cid, cidr_dhcp)
    cmd = []
    cmd << 'sudo'
    cmd << 'pipework'
    cmd << net_name
    cmd << cid
    cmd << cidr_dhcp
    cmd
  end

  def Dokr.hostname(cid)
    cmd = []
    cmd <<  'docker'
    cmd << 'inspect'
    cmd << "--format='{{.Config.Hostname}}'"
    cmd << cid
    cmd
    `#{cmd.join ' '}`.strip
  end
end
