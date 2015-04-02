namespace :run do
  desc "run main"
  task :main, [:opts, :env] do |t, arg| 
    task('run:cmd').reenable
    task('run:cmd').invoke('Main', arg.opts, arg.env, SRC_DIR)
  end

  task :cmd, [:cmd, :opts, :env, :dir] do |t, arg| 
    arg.with_defaults(cmd: 'Main', opts: '', env: '', dir: SRC_DIR + '/web')
    cmd = "#{arg.cmd} #{arg.opts}".split.map{|e|e.strip}.join(' ')
    env_vars = arg.env == '' ? [] : arg.env.split
    p env_vars
    puts "#{arg.dir}".green
    Dir.chdir arg.dir do
      if env_vars.empty?
        sh "./#{cmd}"
      else
        envs = env_vars.map{|e|"export #{e}"}.join(' && ')
        sh "#{envs} && ./#{cmd}"
      end
    end
  end
end
