namespace :cloud do
  desc "make an instance/containers: [lxc]"
  task :make, [:name,:num,:cloud] do |t,arg|
    raise "error: \"name\" is required" if arg.name.nil?
    arg.with_defaults(:num => 1, :cloud => 'lxc')
    name = arg.name
    num = arg.num.to_i
    cloud = arg.cloud
    (0...num).to_a.each do |i|
      puts i
      if num == 1
        sh "rake lxc:make[#{name}]"
      else
        name2 = name+"."+i.to_s
        sh "rake lxc:make[#{name2}]"
      end
    end
  end

  namespace :haskell do
    # raise "../cloud-haskell doesn't exist".red unless Dir.exists? '../cloud-haskell'
    desc "install cloud haskell into this project's .cabal-sandbox:)"
    task :install do
      sh "ln -fs ../cloud-haskell ."
      sh "cd cloud-haskell && make reset"
      sh "cd cloud-haskell && make"
      sh "cd cloud-haskell && make force-install"
    end
  end
end
