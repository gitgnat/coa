namespace :ghc do
  VERSION = '7.10.1' #GHC_VERSION
  PREFIX = "/opt/ghc#{VERSION}"

  task :run, [:src] do |t, arg|
    ENV['PORT'] = '9090'
    sh "cabal exec runhaskell #{PROJ_DIR}/src/web/#{arg.src}"
  end

  desc "print ghc-package dependencies"
  task :pkgs do
    puts GHC_PACKAGE_PATH
  end
  task :packages => :pkgs

  desc "install ghc-#{VERSION}"
  task :install => 'make:install'

  desc "info"
  task :info do
    puts VERSION
    puts PREFIX
  end

  namespace :make do
    VER = VERSION
    GHC_URL = "http://www.haskell.org/ghc/dist/#{VER}/ghc-#{VER}-src.tar.bz2"
    GHC_TAR = "/var/tmp/#{GHC_URL.split('/').last}"
    GHC_DIR = "/var/tmp/#{GHC_URL.split('/').last.split('-src').first}"

    task :install => :build do
      sh "cd #{GHC_DIR} && sudo make install"
    end

    task :build => [:pkgs, GHC_DIR] do
      sh "cd #{GHC_DIR} && ./configure --prefix=#{PREFIX} CFLAGS=-O2"
      sh "cd #{GHC_DIR} && make -j 8"
    end

    task :pkgs do
      sh "sudo apt-get install -y ncurses-dev"
    end

    directory GHC_DIR => GHC_TAR do |t|
      sh "cd /var/tmp && tar xf #{GHC_TAR}"
      sh "cd #{GHC_DIR} && ./configure --prefix=#{PREFIX} CFLAGS=-O2"
    end

    file GHC_TAR do |t|
      sh "wget -c -O #{t.name} #{GHC_URL}"
    end

    task :clean do
      [GHC_TAR,GHC_DIR].each do |d|
        sh "rm -rf #{d}"
      end
    end
  end
end
