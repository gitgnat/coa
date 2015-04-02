namespace :cabal do
  desc "install cabal-sandbox packages"
  task :install, [:allow_newer] => [:init, :update] do |t,arg|
    allow_newer = arg.allow_newer.nil? ? '' : '--allow-newer'
    Dir.chdir(PROJ_DIR) do
      cabal_list = []
      File.readlines('./lib/cabal.list').map{|l|l.strip}.each do |cab|
        next if cab =~ /^\s*#.*$/ || cab =~ /^\s*$/
        cabal = cab.split.join('-')
        cabals = `cabal list --installed --simple-output`.split("\n").map{|l|l.split.join('-')}
        unless cabals.include?(cabal)
          cabal_list << cabal
        else
          puts "#{cabal}".red + " installed already"
        end
      end
      if cabal_list.size > 0
        sh "cabal update"
        cabal_list.each do |pkg|
          puts "intalling #{pkg}".green
          sh "cabal install -j #{allow_newer} #{pkg}"
          puts "#{pkg} installed".red
        end
        sh "rake cabal:backup"
      end
    end
  end

  desc "unregister"
  task :unregister, [:cabal] do |t,arg|
    sh "cabal sandbox hc-pkg -- unregister #{arg.cabal} --force"
  end

  desc "remote cabal list"
  task :rlist, [:cabal] do |t,arg|
    task('cabal:list').invoke(arg.cabal,'r')
  end

  desc "list cabal-sandbox packages"
  task :list, [:cabal, :remote] do |t,arg|
    Dir.chdir(PROJ_DIR) do
      if arg.cabal.nil?
        sh "cabal list --verbose --installed --simple-output"
      else
        if arg.remote.nil?
          sh "cabal list --verbose --installed --simple-output #{arg.cabal}"
        else
          sh "cabal list --verbose --simple-output #{arg.cabal}"
        end
      end
    end
  end

  desc "cabal update"
  task :update do
    Dir.chdir PROJ_DIR do 
      sh "cabal update"
    end
  end

  desc "update each cabal in lib/cabal.list"
  task :update_list do
    Dir.chdir PROJ_DIR do
      list = File.open(LIB_DIR + '/cabal.list').read
      list.gsub!(/\s*\r\n?/, "\n")
      list.each_line.sort_by{|w|w.downcase}.each do |l|
        next if l =~ /^\s*$/ || l =~ /^\s*#/ 
        cabal, version = l.split
        l = cabal_list(cabal)
        if l.last.first == cabal
          if l[-1].last == version
            printf "%23s %-23s\n", "#{l.last.first}-#{l.last.last}", 'current'
          else
            printf "%23s %-23s\n".cyan, "#{cabal}-#{version}", "#{l.last.first}-#{l.last.last}"
          end
        end
      end
    end
  end

  # cabal/version pairs: [[cabal,version],...]
  def cabal_list(cabal)
    l = []
    `cabal list --verbose --simple-output #{cabal}`.each_line do |line|
      elems = line.split(/\s+/)
      if cabal.downcase == elems.first.downcase
        l << elems unless elems.empty?
      end
    end
    l
  end
  
  desc "init. your cabal sandbox"
  task :init, [:force] do |t,arg|
    unless Dir.exists?("#{PROJ_DIR}/.cabal-sandbox") && arg[:force].nil?
      Dir.chdir PROJ_DIR do
        sh "rake cabal:sandbox"
        sh "rake cabal:install"
      end
    end
  end

  task :sandbox do
    sh "cabal sandbox init"
    # use current cabal
    sh "cabal install cabal-install"
    sh "cabal update"
  end

  task :add_src, [:src] do |t,arg|
    sh "cabal sandbox add-source #{arg.src}"
  end

  task :clobber do
    sh "rm -rf #{PROJ_DIR}/.cabal-sandbox"
    sh "rm -f #{PROJ_DIR}/cabal.sandbox.config"
  end

  task :reset do
    sh "rake cabal:clobber cabal:init"
  end
end
