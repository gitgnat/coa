namespace :docker do
  desc "start a docker container by image image"
  task :start, [:image, :opts, :debug] do |t,arg|
    raise ":image of image is nil" if arg.image.nil?
    arg.with_defaults(opts: '')
    cmd = Dokr.run(arg.image, arg.opts, !arg.debug.nil?) # an array 
    sh cmd.join(' ')
  end

  desc "attach to a runing docker container"
  task :attach, [:name_id] do |t,arg|
    raise "no container name/ID".red if arg.name_id.nil?
    sh "docker attach #{arg.name_id}"
  end

  desc "exec a command in a container"
  task :exec, [:name_id, :cmd, :opts, :exec_opts] do |t,arg|
    raise "no container name/ID".red if arg.name_id.nil?
    arg.with_defaults(opts:'', cmd:'/bin/bash')
    exec_opts = if arg.exec_opts.nil?
                  case arg.cmd 
                  when /^\/bin\/(a|ba|k|z)?sh$/
                    [] << '--interactive' << '--tty=true' 
                  else
                    []
                  end
                else
                  arg.exec_opts.split
                end
    begin
      sh "docker exec #{exec_opts.join(' ')} #{arg.name_id} #{arg.cmd}"
    rescue 
      x = $!
      name_ids = `docker ps --filter=[status=running] | grep #{arg.named_id}:`.lines
      if name_ids.length == 1
        name_id = name_ids.first.split.first
        puts "retrying with id(image_name) = container ID".green
        sh "docker exec #{exec_opts.join(' ')} #{name_id} #{arg.cmd}"
      else
        raise x
      end
    end
  end

  desc 'make container: docker_dir in lib/docker'
  task :mk, [:name] do |t,arg|
    raise "no docker_dir arg.".red if arg.name.nil?
    docker_dir = "#{PROJ_DIR}/lib/docker/#{arg.name}"
    Dir.chdir docker_dir do
      sh "cp -fp #{PROJ_DIR}/bin/register ." # wanted to use symlinks but docker doesn't honor them
      sh "docker build --tag=#{arg.name} ."
    end
  end

  desc 'docker dirs'
  task :dirs do
    puts "#{LIB_DIR}/docker".green
    `ls -1 #{LIB_DIR}/docker`.split.each do |l|
      puts '  ' + l.yellow
    end
  end
  task :images => :dirs

  desc 'info'
  task :info do
    v = `docker --version`.strip
    puts "#{v}".cyan
    d = `which docker`.strip
    puts "#{d}".green
    task :start, [:name,:opts,:debug] do |t,arg|
      raise ":name of image is nil" if arg.name.nil?
      cmd = []
      cmd << 'docker run'
      cmd << arg.opts
      if arg.debug.nil?
        cmd << '--detach'
      else
        cmd << '--interactive'
        cmd << '--user=root'
        cmd << '--entrypoint=/bin/bash'
      end
      cmd << arg.name
      sh cmd.join ' '
    end

    msg = <<EOF
for memory and swap accounting, run the following:
  if you want to enable memory and swap accounting, you must add the following 
  command-line parameters to your kernel:

  $ cgroup_enable=memory swapaccount=1

  Add the above parameters by editing /etc/default/grub and extending 
  GRUB_CMDLINE_LINUX. Look for the following line:

  $ GRUB_CMDLINE_LINUX=""

  And replace it with the following:
  $ GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

  $ sudo update-grub
  $ reboot
EOF
    puts msg.strip.yellow
  end

  desc "non-root (user) access"
  task :user_access do
    sh "sudo groupadd docker || exit 0"
    sh "sudo gpasswd -a #{ENV['LOGNAME']} docker"
    puts "type rake docker:restart".red
  end

  desc 'install docker'
  task :install => 'docker:install:docker'

  desc "list containers"
  task :list do
    sh "docker ps --all"
  end
  task :ls => :list

  task :ids do
    sh 'docker ps --quiet'
  end
  
  desc "ips and other metadata"
  task :ips do
    head, *ds = `docker ps --all`.each_line.map{|l|l.split}
    ds.each do |l|
      id = l[0].strip
      ip = `docker inspect --format '{{.NetworkSettings.IPAddress}}' #{id}`.strip
      o = {id: id, ip: ip, image: l[1], entrypoint: l[2], name: l.last}
      printf "%-16s %-13s %s %s\n", o[:ip], o[:id], o[:name], o[:image]
    end
  end

  desc "stop all or an individual container"
  task :stop, [:cid] do |t,arg|
    cs = if arg.cid.nil?
           docker_ps
         else
           [arg.cid]
         end
    cs.each do |c|
      begin 
        puts "#{docker_cmd('stop', '', c)} stopped"
      rescue
        puts "#{$!}".red
      end
    end
  end

  desc "clean (remove) stopped containers"
  task :clean, [:cid, :opt] do |t,arg|
    arg.with_defaults(opt: '')
    cs = if arg.cid.nil?
           docker_ps
         else
           [arg.cid]
         end
    cs.each do |c|
      cs.each do |c|
        begin 
          puts "#{docker_cmd('rm', arg.opt, c)} removed"
        rescue
          puts "#{$!}".red
        end
      end
    end
  end

  desc "clobber: stop and clean"
  task :clobber, [:cid, :opt] do |t,arg|
    arg.with_defaults(opt:'')
    cs = if arg.cid.nil?
           docker_ps
         else
           [arg.cid]
         end
    cs.each do |c|
      cs.each do |c|
        begin 
          puts "#{docker_cmd('stop', arg.opt, c)} stopped"
          puts "#{docker_cmd('rm', arg.opt, c)} removed"
        rescue
          puts "#{$!}".red
        end
      end
    end
  end

  def docker_ps 
    dout = docker_cmd('ps', '--all --quiet')
    if dout.nil? || dout.empty?
      []
    else
      dout.split
    end
  end

  def docker_cmd(c, cid, opt ='') 
    dout = `docker #{c} #{opt} #{cid}`.strip
  end

  # container
  namespace :image do
    desc "list images"
    task :ls do
      begin
        sh "docker images --all"
      rescue
        puts $!
      end
    end
    task :list => :ls

    desc "clean (remove) untagged containers"
    task :clean => :rm
    task :rm, :cid do |t,arg|
      begin
        if arg.cid.nil?
          sh "docker images --all --filter=[dangling=true] --quiet | xargs docker rmi --force"
        else
          sh "docker rmi --force #{arg.cid}"
        end
      rescue
        puts $!
      end
    end

    desc "clobber: remove all images"
    task :clobber do
      image_ids = `docker images --all --quiet`.each_line.map{|l|l.strip}
      while !image_ids.empty? do
        ids = image_ids.pop 10
        sh "docker rmi --force #{ids.join(' ')}"
      end
    end
  end

  namespace :daemon do
    desc 'restart docker daemon'
    task :restart, [:opts] do |t,arg|
      arg.with_defaults(opts: '--dns 192.168.16.10')
      ENV['DOCKER_OPTS'] = "'#{arg.opts}'"
      sh 'sudo --preserve-env service docker restart'
    end

    desc 'stop docker daemon'
    task :stop do
      sh 'sudo service docker stop'
    end

    desc 'start docker daemon'
    task :start, [:opts] do |t,arg|
      arg.with_defaults(opts: '--dns 192.168.16.10')
      ENV['DOCKER_OPTS'] = "'#{arg.opts}'"
      sh 'sudo --preserve-env service docker start'
    end
  end

  namespace :install do
    DOCKER_LIST = '/etc/apt/sources.list.d/docker.list'

    desc 'install docker'
    task :docker => [:keychain, :repo, :update, :install]

    desc "apt-get install lxc-docker"
    task :install do
      sh "sudo apt-get install -y lxc-docker"
    end

    desc "install /etc/default/docker--has site dns"
    task :config => :user_access do
      unless File.exists? "/etc/default/docker-"
        sh "sudo cp --preserve=all /etc/default/docker /etc/default/docker-"
      end
      Dir.chdir "#{PROJ_DIR}/lib/etc/default" do
        sh "sudo cp docker /etc/default/"
        sh "sudo chown root /etc/default/docker"
        puts "restart docker, type the following: ".yellow + "rake docker:daemon:restart".green
      end
    end

    desc "non-root (user) access"
    task :user_access do
      sh "sudo groupadd docker || exit 0"
      sh "sudo gpasswd -a #{ENV['LOGNAME']} docker"
      puts "type rake docker:restart".red
    end

    desc "apt-get update"
    task :update do
      sh "sudo apt-get update -y"
    end

    desc 'repo source'
    task :repo do
      sh "sudo sh -c 'echo deb https://get.docker.io/ubuntu docker main > #{DOCKER_LIST}'"
    end

    desc "add docker-repo keychain"
    task :keychain do
      KEYSERVER = 'hkp://keyserver.ubuntu.com:80'
      RECV_KEY = '36A1D7869245C8950F966E92D8576A8BA88D21E9'
      sh "sudo apt-key adv --keyserver #{KEYSERVER} --recv-keys #{RECV_KEY}"
    end

    # some useful utilities nsenter and pipework
    desc "install nsenter"
    task :nsenter do
      puts "ignoring: nsenter not needed anymore".yellow
      exit 0 # not needed anymore
      unless File.exists? "/usr/local/bin/nsenter"
        begin
          sh "docker run --rm --volume /var/tmp:/target jpetazzo/nsenter"
          sh "sudo mv -f /var/tmp/nsenter /usr/local/bin/"
        ensure
          sh "docker rmi --force jpetazzo/nsenter"
        end
      else
        puts "nop: /usr/local/bin/nsenter already installed".yellow
      end
    end

    desc 'install pipework (SDN)'
    task :pipework do
      Dir.chdir('/var/tmp') do
        sh "git clone https://github.com/jpetazzo/pipework" unless Dir.exists? 'pipework'
        sh "sudo cp /var/tmp/pipework/pipework /usr/local/bin"
        sh "sudo apt install -y udhcpc"
        sh "rm -rf pipework" if Dir.exists? 'pipework'
      end
    end
  end
end
