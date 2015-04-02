namespace :init do
    desc "create and seed a new ghc project"
    task :proj, [:name] do |t,arg|
        raise "new project name required, e.g.: rake init:proj[tim]" if arg.name.nil?
        NEW_PROJ_DIR = File.expand_path("#{PROJ_HOME}/../#{arg.name}")
        sh "rake dev:rsync_proj[#{arg.name},true]"
        Dir.chdir("#{NEW_PROJ_DIR}") do
            sh "git init"
            puts "new proj " + arg.name.green + " created"
            puts "run: cd #{arg.name} && rake dev:init".red
        end
    end
end
