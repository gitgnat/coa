namespace :app do
  require 'yaml'
  APP_DIR = "#{PROJ_DIR}/lib/docker/App"

  desc "make all images that define an app"
  task :mk, [:app_name] do |t,arg|
    raise "name is nil" if arg.app_name.nil?
    yaml = YAML.load_file "#{APP_DIR}/#{arg.app_name}.yaml"
    nodes = yaml['app']['docker_nodes']
    #nodes.map{|n|n['image']}.each do |image|
    nodes.each do |node|
      next if node['disable']
      image = node['image']
      puts "building image: #{image}".cyan
      sh "rake docker:mk[#{image}]"
      puts "built image: #{image}".green
    end
  end

  desc "clean app state, i.e., containers and named containers"
  task :clean, [:app_name] do |t,arg|
    sh "rake docker:stop"
    sh "rake docker:clean"
  end

  desc "reset docker and dev network"
  task :reset => [:clean] do
    sh "rake net:rem"
  end

  desc "ls"
  task :ls, [:app] do |t,arg|
    if arg.app.nil?
      ys = `ls #{PROJ_DIR}/lib/docker/App`.each_line.map{|l|l.strip}.map do |e|    
        cs = e.split '.'
        [cs.first, e]
      end
      ys.each do |y|
        printf "%-32s lib/docker/App/%s\n", y.first, y.last
      end
    else
      yaml = YAML.load_file "#{APP_DIR}/#{arg.app}.yaml"      
      yaml['app']['docker_nodes'].each do |node|
        puts "#{node['image']} :: #{node['name']}"
        p 
      end
    end
  end

  def running_container_names
    head, *tail = `docker ps`.each_line.map{|l|l.split}
    imgs = tail.map do |l|
      id = l[0].strip
      ip = `docker inspect --format '{{.NetworkSettings.IPAddress}}' #{id}`.strip
      #o = {id: id, ip: ip, image: l[1], entrypoint: l[2], name: l.last}
      l[1].split(':').first
    end.sort
    imgs
  end

  desc "start all docker containers defining an app or one container within said app"
  task :start, [:app, :app_name, :docker_opts, :debug, :volumes] do |t,arg|
    raise "app is nil" if arg.app.nil?
    arg.with_defaults(dev_mode:'', docker_opts:'')
    yaml = YAML.load_file "#{APP_DIR}/#{arg.app}.yaml"

    net = yaml['app']['network']
    sh "rake net:mk[#{net['name']},#{net['cidr']}]"
    running_names = running_container_names
    nodes = if arg.app_name.nil?
              yaml['app']['docker_nodes']
            else
              yaml['app']['docker_nodes'].select{|n| n['image'] == arg.app_name}
            end
    nodes.each do |node|
      next if !node['disable'].nil? && node['disable']
      instances = node['instances'].nil? ? 1 : node['instances'].to_i
      unless running_names.include? node['image']
        (0...instances).each do |i|
          vols = arg.volumes.nil? ? [] : arg.volumes.split
          mk_container(node, i, arg.docker_opts, !arg.debug.nil?, vols)
        end
      else
        printf "%s image already started\n", node['image'].cyan
      end
    end    
  end

  def mk_container(node, index, docker_opts, debug =false, vols =[])
    raise "image is empty" if [nil,''].include? node['image']
    unless node['delay_start'].nil?
      puts "delayed start: " + node['image'].red + "; sleep=#{node['delay_start']}s"
      sleep node['delay_start'].to_i
    end
    image = node['image']
    cidr = node['cidr']
    env = node['env']
    %w(image cidr instances delay_start).each do |k|
      node.tap{|h| h.delete k}
    end
    # @hack: this is gross but no other way to do this with yaml
    opts = env.nil? ? [] : env.flatten.map{|e| "--env='#{e}'"}
    # opts += h.map do |k,v|
    #   val = k == 'name' ? (index == 0 ? v : "#{v}.#{index}") : v
    #   "--#{k}=#{val.to_s}"
    # end
    opts << docker_opts unless docker_opts == ''
    # @todo: refactor and remove this grossness
    if cidr.nil?
      run = Dokr.run(image, opts.join(' '), debug)
      sh run.join ' '
    else
      task('net:add').reenable
      unless debug
        task('net:add').invoke(image, cidr, DEVNET_NAME, opts.join(' '))
      else
        task('net:add').invoke(image, cidr, DEVNET_NAME, opts.join(' '), 'd')
      end
    end

    {image: image, cidr: cidr}
  end
end
