require "bundler/capistrano"
require "rvm/capistrano"

server "104.236.95.77", :web, :app, :db, primary: true

set :application, "runspool"
set :user, "root"
set :port, 22
set :deploy_to, "/home/rails/"
set :deploy_via, :remote_cache
set :use_sudo, false
set :rvm_type, :system

set :scm, "git"
set :repository, "git@bitbucket.org:dgmdan/runspool.git"
set :branch, "master"


default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn #{command}"
    end
  end
end
