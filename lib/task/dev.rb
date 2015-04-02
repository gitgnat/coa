require 'rubygems'
require 'bundler/setup'
require 'date'
require 'yaml'
require 'smart_colored/extend'

def sys_name
  s = `uname -s`.strip.downcase
  s = `lsb_release --id`.split.last.strip.downcase if 'linux' == s
  s
end

def sys_name?(p)
  sys_name == p.strip.downcase
end

def platform?(p)
  `uname -s`.strip.downcase == p.downcase
end

def fay_src_dir?(dir)
  if dir.nil?
    false
  else
    FAY_SRC_DIR.include? dir.split('/').last
  end
end

def proj_dir(subdir =nil)
  path = [] << PROJ_DIR
  path << subdir unless subdir.nil?
  path.join('/')
end

def process_running?(name, argfilter =nil)
  require 'sys/proctable'
  include Sys
  ProcTable.ps do |proc|
    # @todo: gross--refactor
    if argfilter.nil?
      return true if proc.comm == name
    else
      return true if proc.comm == name && proc.cmdline.split.include?(argfilter)
    end
  end
  false
end

def proj_mode
  ENV['PROJ_MODE'].nil? ? 'DEV' : ENV['PROJ_MODE']
end

def install_pkg(pkgs =[], sysname =sys_name)
  update, install = case sysname
                    when 'centos'
                      ['sudo yum update -y', 'sudo yum install -y']
                    when 'darwin'
                      ['brew update -y', 'brew install']
                    when 'ubuntu'
                      ['sudo apt-get update -y', 'sudo apt-get install -y']
                    else
                      raise "unknown system--not in {centos,darwin,ubuntu}"
                    end
  sh "#{update}"
  sh "#{install} #{pkgs.join(' ')}"
end

def version(bin, arg ='--version')
  puts `which #{bin}`.strip.green
  `#{bin} #{arg}`.split(/\n/).map{|l|puts "- #{l.strip}".yellow}
end

PROJ_DIR = File.expand_path("#{File.dirname(__FILE__)}/../../.")
SRC_DIR = proj_dir 'src'
ETC_DIR = proj_dir 'etc'
LIB_DIR = proj_dir 'lib'
DIST_DIR = proj_dir 'dist'
TASK_DIR = proj_dir 'lib/task'
DOCKER_DIR = proj_dir 'lib/docker'
SANDBOX_DIR = proj_dir '.cabal-sandbox'
# @NB: add dirs as required, e.g.: ./src/client generates Javascript from Haskell code
FAY_SRC_DIR = %w[client examples]
FAY_GEN_HTML = {'client' => 'Main.hs'}

PROJ_HOME = PROJ_DIR
OPT_DIR = '/opt'

DEVNET_NAME = 'dev0'
DEVNET_CIDR = '192.168.16.1/24'

os = `uname -s`.strip.downcase
OS = case os
     when 'darwin'; 'osx'
     when 'linux'; 'linux'
     else raise "unknown OS: #{os}"
     end

GHC_VERSION = '7.10.1'
CABAL_VERSION = '1.22.2.0'
GHC_PACKAGE_PATH  = "#{PROJ_DIR}/.cabal-sandbox/x86_64-#{OS}-ghc-#{GHC_VERSION}-packages.conf.d"
CABAL_SANDBOX_DIR = "#{PROJ_DIR}/.cabal-sandbox"
GHC = 'ghc'

FAY = "fay"

_path = []
_path << "#{PROJ_DIR}/bin"
_path << "#{PROJ_DIR}/.cabal-sandbox/bin"
_path << "/opt/ghc#{GHC_VERSION}/bin"
_path << '/usr/local/bin'
_path << '/usr/bin'
_path << '/bin'

ENV['SHELL'] = '/bin/bash'
ENV['PATH'] = _path.join(':')
ENV['JAVA_HOME'] = '/usr/lib/jvm/java-8-oracle'
ENV['PROJ_MODE'] = 'DEV'
ENV['HASKELL_PACKAGE_SANDBOX'] = GHC_PACKAGE_PATH
