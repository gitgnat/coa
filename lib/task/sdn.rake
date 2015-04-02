namespace :sdn do
  require 'yaml'
  SDN_DIR = "#{PROJ_DIR}/etc/sdn"

  desc 'create and start a dev sdn: dev0'
  task :start, [:yaml] do |t,arg|
    raise "yaml is nil" if arg.yaml.nil?
    y = YAML.load_file "#{SDN_DIR}/#{arg.yaml}"
    sdn = y['sdn']
    net = y['sdn']['network']
    task('net:mk').invoke(net['name'],net['cidr'])
    sdn['docker_nodes'].each do |node|
      instances = node['instances'].nil? ? 1 : node['instances'].to_i
      (0...instances).each do |i|
        sh "bundle exec rake net:add[#{node['image']},#{node['cidr']}]"
      end
    end
    #sh "bundle exec rake net:mk[#{y['network']['name']}]"
  end
end

