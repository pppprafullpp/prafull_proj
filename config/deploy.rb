# config valid only for Capistrano 3.1
set :application, 'servicedeals'
set :repo_url, 'https://github.com/ramgarg/Service-Deals-Rails.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/dev/servicedeals'

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :rvm_ruby_version, '2.2.2'
set :default_env, { rvm_bin_path: '~/.rvm/bin' }
SSHKit.config.command_map[:rake] = "#{fetch(:default_env)[:rvm_bin_path]}/rvm ruby-#{fetch(:rvm_ruby_version)} do bundle exec rake"

set :bundle_binstubs, nil

#set :whenever_command, "bundle exec whenever"
#set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end

#namespace :deploy do
#  desc "Update crontab with whenever"
#  task :update_cron do
#    on roles(:app) do
#      within current_path do
#        execute :bundle, :exec, "whenever --update-crontab #{fetch(:application)}"
#      end
#    end
#  end

#  after :finishing, 'deploy:update_cron'
#end
