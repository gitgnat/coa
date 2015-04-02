namespace :openvswitch do
  desc "install packages"
  task :install, [:pkgs] do |t,arg|
    packages = if arg.pkgs.nil?
                 %w(openvswitch-common openvswitch-datapath-dkms openvswitch-datapath-source openvswitch-switch)
               else
                 arg.pkgs.split /\s+/
               end
    packages.map{|pkg|"sudo apt-get install -y #{pkg}"}.each do |cmd|
      sh cmd
    end
  end
  
  desc "start open vswitch"
  task :start do
    sh "sudo start openvswitch-switch"
  end
end
