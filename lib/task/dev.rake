# -*- coding: utf-8 -*-
namespace :dev do
  desc "start dev within a docker container"
  task :docker, [:app, :app_image] do |t,arg|
    raise "missing argument(s)" if arg.app.nil? || arg.app_image.nil?
    cmd = %w(/etc/passwd /etc/shadow /etc/group /etc/sudoers /etc/sudoers.d/).map do |e| 
      "--volume=#{e}:#{e}"
    end
    cmd << '--dns=10.8.30.11 --dns=10.8.30.3'
    cmd << '--name=jepsen-dev'
    cmd << "--volume=/home/#{ENV['LOGNAME']}:/home/#{ENV['LOGNAME']}"
    cmd << "--workdir=/home/#{ENV['LOGNAME']}"
    cmd << "--user=#{ENV['LOGNAME']}"
    sh "rake docker:start[#{arg.app_image},'#{cmd.join ' '}',d]"
  end

  def make_all(src_dir)
    make(src_files(src_dir), src_dir, 'Main')
  end
  
  desc "start dev."
  task :start, [:dir] do |t, arg|
    require 'listen'
    arg.with_defaults(:dir => 'src')
    src_dir = proj_dir arg.dir

    puts src_dir if ENV['VERBOSE']

    make_all(src_dir)
    @listener = Listen.to('.', only: /(\.hs|Main|Spec)$/, ignore: /\.#/) do |mod, add, rem|
      if (add + mod + rem).uniq.select{|e|e.match /\.hs$/}.any?
        make_all(src_dir)
      elsif !rem.empty? # Main or Spec
        rem.each do |r|
          name = r.split('/').last
          case name
          when'Main'
            make(src_files(src_dir), src_dir)
          when'Spec'
            make(src_files(src_dir, spec=true), src_dir, 'Spec')
          else 
            puts "noop: "
          end
        end
      end
    end

    @listener.start
    trap('SIGINT') {@listener.stop; exit}
    sleep
  end
  
  desc "make app (dir)"
  task :make, [:dir] do |t,arg|
    arg.with_defaults(:dir => 'web')
    src_dir = proj_dir "src/#{arg.dir}"
    puts "building #{src_dir}".green
    make(src_files(src_dir), src_dir, 'Main', '-O2 -optl-pthread')
    make(src_files(src_dir, spec=true), src_dir, 'Spec')
  end
  
  desc "run all tests (specs)"
  task :test => :spec

  desc "run specs"
  task :spec do
    puts "@todo: implement".red
  end
  
  desc "install app"
  task :install, [:dir, :name] do |t,arg|
    arg.with_defaults dir:'/var/tmp/edu', name:'edu'
    puts "@todo: implement".red
  end
  
  desc "clean"
  task :clean, [:dir] do |t,arg|
    dir = arg.dir.nil? ? SRC_DIR : proj_dir(arg.dir)
    puts dir.cyan
    Dir.chdir dir do
      bins = ['Spec', 'Main']
      exts = ['*.o', '*.dyn_o', '*.hi', '*.dyn_hi', '*.hc']
      files = bins + exts
      fs = FileList.new(files.map{|f|"./**/#{f}"}).join(' ')
      sh "rm -f #{fs}" unless fs == '' 
    end
  end
  
  desc "clean: rm -rf ./dist/*"
  task :clean_dist do
    sh "rm -rf ./dist/*"
  end

  desc "ghci"
  task :ghci, [:dir] do |t,arg|
    cwd = arg.dir.nil? ? proj_dir('src') : proj_dir("src/#{arg.dir}")
    unless Dir.exists?(File.expand_path('~/.ghci'))
      File.open(File.expand_path('~/.ghci'),'w'){|f|f.write(dot_ghci)}
    end
    puts cwd.green
    Dir.chdir(cwd) do
      sh "export GHC_PACKAGE_PATH=#{GHC_PACKAGE_PATH}:; ghci -cpp"
    end
  end
  
  desc "graphical rep. of \"git diff\""
  task :diff, [:csv] do |t,arg|
    arg.with_defaults(csv: "")
    if arg[:csv].empty?
      sh "gdiff"
    else
      arg[:csv].split.each{|f| sh "gdiff #{f}"}
    end
  end

  desc "init dev. env.: cabal-dev install"
  task :init => [:pkgs, :gems, :dev_env]

  task :dev_env do
    %w(install ghc cabal happy alex).each do |t|
      puts t.red
    end
    sh "mkdir -p #{DIST_DIR}/edu"
    sh "rake cabal:init"
  end

  desc "install packages"
  task :pkgs do
    sh "sudo apt-get update -y"
    PS = [] << 'openvswitch-common'
    PS << 'openvswitch-switch'
    PS << 'libpq-dev'
    sh "sudo apt-get install -y #{PS.join(' ')}"
  end

  desc "reset (remove cabal-dev) dev. env."
  task :reset => [:clean] do
    task('cabal:clean').invoke
  end

  desc "install gems"
  task :gems do
    gems = [] << ['smart_colored','1.1.1']
    gems << ['sys-proctable','0.9.3']
    gems << ['listen','1.3.0']
    gems.each do |gem,version|
      sh "gem list --installed --version=#{version} #{gem}" do |ok,res|
        if ok
          puts "#{gem}-#{version} " + "already installed".green
        else
          sh "sudo gem install --no-ri --no-rdoc --version=#{version} #{gem}"
        end
      end
    end
  end

  desc "update dev env., e.g.: cabal:update"
  task :update do
    sh "rake cabal:update"
  end

  desc "info"
  task :info do
    puts PROJ_HOME.red
    puts "- PATH=#{ENV['PATH']}".yellow
    puts "- GHC=#{GHC}".cyan
    ['ghc','cabal'].each{|c|version(c)}
  end

  # cabal may not be needed--static compilation may not require external packages
  def cabal(arg)
    arg.with_defaults(:dev => 'dev')
    if arg[:dev] == 'prod'
      'cabal'
    else
      'cabal-dev'
    end
  end

  desc "rsync/init a GHC project"
  task :rsync_proj, [:proj_name,:delete] do |t,arg|
    arg.defaults(delete:'false')
    PROJ_DIR = File.expand_path("#{File.dirname(__FILE__)}/../../../.")
    Dir.chdir(PROJ_DIR) do
      sh "mkdir -p arg.proj_name"
      rsync = [] << "rsync -axv --exclude .git --exclude '*~*'"
      if arg.delete =~ /^(del|delete)$/
        rsync << '--delete --delete-excluded'
      end
      rsync << "#{PROJ_HOME}/"
      rsync << "#{PROJ_DIR}/#{arg.proj_name}/"
      sh "#{rsync.join(' ')}"
    end
    Dir.chdir("#{PROJ_DIR}/#{arg.proj_name}") do
      ['bin','etc','src'].each do |dir|
        sh "mkdir -p #{dir}" unless Dir.exists?(dir)
      end
      sh "git init" unless Dir.exists?('.git')
    end
  end

  def make(src, dir, name ='Main', opts ='-Wall')
    ghc_opts = []
    ghc_opts << '-XBangPatterns'
    ghc_opts << '-no-user-package-db -package-db'
    ghc_opts << GHC_PACKAGE_PATH
    ghc_opts << '-rtsopts'
    ghc_opts << '-threaded'

    ghc_opts << opts
    Dir.chdir dir do
      compiler = "#{GHC} #{ghc_opts.join(' ')} --make #{src} -o #{name} 2>&1"
      puts compiler.yellow unless ENV['DEBUG'].nil?
      [`pwd`, compiler].each{|e|puts e.strip} if ENV['VERBOSE']
      success = popen(compiler, name)
      sh "rm -f ./#{name}" unless success
    end
  end
  
  def src_files(src_dir, spec =false)
    Dir.chdir src_dir do
      pat = ['*/**/*.hs', '*.hs']
      if fay_src_dir? src_dir
        FileList.new(pat).join(' ')
      else
        re = spec ? /.*Main\.hs$|.+\/.*Spec\.hs/ : /.*Spec\.hs$|.+\/.*Main\.hs/
        FileList.new(pat).exclude(re).join(' ')
      end
    end
  end
  
  def compiler(src)
    FileList[src].ext('o').each{|f|File.delete(f) if File.exists?(f)}
    (src.class == String ? [src] : src).each do |f|
      puts "#{GHC} -c #{f}".yellow
      IO.popen("#{GHC} -c #{f} 2>&1") do |io|
        Process.wait(io.pid)
        putsh($? == 0, io.readlines.select{|l|l.size > 0}, __callee__)
        io.close
        if $? != 0
          puts "status=#{$?}"
          return false
        end
      end
    end
    true
  end
  
  def popen(cmd, name)
    success = false
    IO.popen(cmd) do |io|
      Process.wait(io.pid)
      success = $? == 0
      begin
        putsh(success, io.readlines.select{|l|l.size > 0}, name)  
      ensure
        io.close
      end
    end
    success
  end

  def putsh(ok, res, app_name)
    res.map{|l|l.rstrip}.select{|l|l != ""}.each do |line|
      l = if line =~ /.*\.hs$/
            line.include?(' ') ? line.white : line.bold
          elsif line =~ /[0-9]+:$/
            line.bold
          elsif line =~ /\[.+\]/
            line.cyan
          else
            line
          end
      puts l
    end
    app = app_name.split('/').last == 'Spec' ? app_name.blue : app_name.green
    r = [] << if ok 
                "+ make ".green + app.bold + " succeeded".green + time
              else
                "- make ".red + app + " failed".red.bold + time
              end
    r.each{|l| puts l}
  end

  def run_bg(pid)
    Process.kill("KILL", pid) unless pid.nil?   
    pid = fork do
      exec "#{SRC_DIR[:web]}/Main"
    end
    Process.detach(pid)
    pid
  end

  def time
    " " + DateTime.now.strftime('%l:%M:%S.%L').to_s
  end

  def dot_ghci
    <<EOF
import Control.Applicative
import Control.Monad
import Control.Concurrent
import Control.Concurrent.Async
import Control.Parallel

import Data.String
import Data.Char
import Data.List
import Data.Monoid
import Control.Monad.IO.Class

:set prompt "λ: "

:set -fno-warn-unused-imports
:def hlint const . return $ ":! hlint \\"src\\""
:def hoogle \\s -> return $ ":! hoogle --count=15 \\"" ++ s ++ "\\""
:def pl \\s -> return $ ":! pointfree \\"" ++ s ++ "\\""
EOF
  end
end

