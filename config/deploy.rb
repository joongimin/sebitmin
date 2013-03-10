require "bundler/capistrano"
load "deploy/assets"

set :application, "sebitmin"

# SSH
set :user, "root"
set :use_sudo, false
set :deploy_to, "/var/www/sebitmin"

# SCM
set :repository,  "nouvaux@git.nouvaux.com:/files/git/sebitmin.git"
set :scm, :git
set :scm_username, "nouvaux"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# Rails3 Asset Pipeline
set :normalize_asset_timestamps, false

#role :web, "w2.nouvaux.com"                          # Your HTTP server, Apache/etc
#role :app, "w2.nouvaux.com"                          # This may be the same as your `Web` server
#role :db,  "w1.nouvaux.com", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

server "ec2-23-22-43-63.compute-1.amazonaws.com", :app, :web, :db, :primary => true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

set :default_environment, {
    'PATH' => "/usr/local/bin:/bin:/usr/bin:/bin:/opt/ruby-enterprise-1.8.7-2012.02/bin",
    'GEM_HOME' => '/opt/ruby-enterprise-1.8.7-2012.02/lib/ruby/gems/1.8',
    'GEM_PATH' => '/opt/ruby-enterprise-1.8.7-2012.02/lib/ruby/gems/1.8',
    'BUNDLE_PATH' => '/opt/ruby-enterprise-1.8.7-2012.02/lib/ruby/gems/1.8/gems'  
}