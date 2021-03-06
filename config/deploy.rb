require "bundler/capistrano" 
require 'new_relic/recipes'

set :application, "TonyBlack"
set :repository,  "https://github.com/JeroenKnoops/tonyblack"

set :location, "54.229.65.0"

set :use_sudo, false

set :default_environment, {
  'PATH' => "/home/admin/.rvm/gems/ruby-1.9.3-p194/bin:/home/admin/.rvm/gems/ruby-1.9.3-p194@global/bin:/home/admin/.rvm/bin:$PATH",
  'RUBY_VERSION' => 'ruby 2.0.0',
  'GEM_HOME'     => '/home/admin/.rvm/gems/ruby-1.9.3-p194@tonyblack',
  'GEM_PATH'     => '/home/admin/.rvm/gems/ruby-1.9.3-p194@tonyblack',
  'BUNDLE_PATH'  => '/home/admin/.rvm/gems/ruby-1.9.3-p194@tonyblack',   
     # If you are using bundler.
  'TERM'         => 'screen-256color',
  "RAILS_ENV"    => "production"
}

set :ssh_options, { :forward_agent => true }

default_environment["RAILS_ENV"] = 'production'
default_run_options[:shell] = 'bash'

role :web, location                          # Your HTTP server, Apache/etc
role :app, location                          # This may be the same as your `Web` server
role :db,  location, :primary => true # This is where Rails migrations will run

set :user, "admin"

set :deploy_to, "/export/tonyblack/tonyblack"
set :deploy_via, :remote_cache

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :install_bundler, :roles => :app do
      run "type -P bundle &>/dev/null || { gem install bundler --no-rdoc --no-ri; }"
  end
end

namespace :remote do
  desc <<-DESC
  Add configuration files for TonyBlack.org
  DESC
  task :create_symblink, :roles => :app do
    print "    creating symlinks to database.yml.\n"
    run "rm /export/tonyblack/tonyblack/current/config/database.yml && ln -s /export/conf/tonyblack/database.yml /export/tonyblack/tonyblack/current/config/database.yml"
    run "ln -s /export/conf/tonyblack/newrelic.yml /export/tonyblack/tonyblack/current/config/newrelic.yml"
    run "rm /export/tonyblack/tonyblack/current/config/initializers/secret_token.rb && ln -s /export/conf/tonyblack/secret_token.rb /export/tonyblack/tonyblack/current/config/initializers/secret_token.rb"
    run "rm /export/tonyblack/tonyblack/current/config/environments/production.rb && ln -s /export/conf/tonyblack/production.rb /export/tonyblack/tonyblack/current/config/environments/production.rb"
  end
end

before 'deploy:migrate', 'remote:create_symblink'

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

after "deploy", "rvm:trust_rvmrc"

before "deploy:cold", 
    "deploy:install_bundler"

after "deploy:update", "newrelic:notice_deployment"
