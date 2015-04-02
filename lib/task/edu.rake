namespace :edu do
  task :default => :docker

  EDU_DOCKER_DIR = "#{DOCKER_DIR}/edu"

  task :docker => [:clean,:install] do
    task('docker:mk').reenable
    task('docker:mk').invoke(EDU_DOCKER_DIR.split('/').last)
  end

  task :install do
    Dir.chdir PROJ_DIR do
      ['dev:clean', 'dev:all', "dev:install[#{EDU_DOCKER_DIR}]"].each do |t|
        sh "bundle exec rake #{t}"
        sh "cp #{ETC_DIR}/edu.yml #{EDU_DOCKER_DIR}"
      end
    end
  end

  task :clean => 'dev:clean' do
    Dir.chdir EDU_DOCKER_DIR do
      sh "rm -f edu edu.yml"
    end
  end
end
