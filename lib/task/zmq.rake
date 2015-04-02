namespace :zmq do
  ZMQ_URL = 'http://download.zeromq.org/zeromq-4.0.4.tar.gz'
  ZMQ_TAR = "/var/tmp/#{ZMQ_URL.split('/').last}"
  ZMQ_DIR = ZMQ_TAR.split('.').first(ZMQ_TAR.split('.').size-2).join('.')

  desc "init: install/configure zmq"
  task :init => [:install]
    
  desc "install zmq from source"
  task :install => [:build] do
    sh "cd #{ZMQ_DIR} && sudo make install"
  end

  task :build => [:pkgs, ZMQ_DIR] do
    sh "cd #{ZMQ_DIR} && make -j 8"
  end

  task :pkgs do
    sh "sudo apt-get install -y ncurses-dev"
  end

  directory ZMQ_DIR => ZMQ_TAR do |t| 
    sh "cd /var/tmp && tar xf #{ZMQ_TAR}"
    sh "cd #{ZMQ_DIR} && ./configure --prefix=#{PROJ_DIR}/opt/zmq CFLAGS=-O2"
  end

  file ZMQ_TAR do |t|
    sh "wget --output-document='#{ZMQ_TAR}' #{ZMQ_URL}"
  end

  task :clean do
    [ZMQ_TAR,ZMQ_DIR].each do |d|
      sh "rm -rf #{d}"
    end
  end

  namespace :cabal do
    directory OPT_DIR
      
    desc "install zero-mq-4 cabal package"
    task :install => OPT_DIR do
      Dir.chdir(OPT_DIR) do
        sh "git clone https://github.com/twittner/zeromq-haskell.git" unless Dir.exists?('zeromq-haskell')
      end
      Dir.chdir(PROJ_DIR) do
        sh "cabal sandbox add-source #{OPT_DIR}/zeromq-haskell"
        sh "cd opt/zeromq-haskell && cabal install --dependencies-only" # install it into sandbox
      end
    end
  end
end

