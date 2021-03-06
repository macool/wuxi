# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'wuxi'
set :repo_url, 'git@github.com:macool/wuxi.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, ENV['BRANCH'] || 'master'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/wuxi/wuxi'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, false
# set :sidekiq_monit_conf_dir, "#{shared_path}/monit_configs"

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
append :linked_files, '.env'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads', 'monit_configs'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :bundle_without, %w{development test deployment}.join(' ')

set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip

set :passenger_restart_with_touch, true

set :default_env, {
  'RAILS_ENV' => fetch(:stage)
}

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:db) do
      within release_path do
        execute :rake, 'db:mongoid:create_indexes'
      end
    end
  end
end
