# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'planning-poker'

set :repo_url, 'git@github.com:koffeinfrei/planning-poker.git'
set :branch, 'master'

set :user, 'app'
set :deploy_to, -> { "/home/#{ fetch(:user) }/app" }
set :ssh_options, -> { { user: fetch(:user), forward_agent: true } }
set :log_level, :info

set :volt_env, 'production'
set :default_env, { volt_env: fetch(:volt_env) }

set :rbenv_ruby, open("#{ Bundler.root }/.ruby-version").read.strip
set :bundle_jobs, 2

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:app), in: :sequence do
      within release_path do
        execute :bundle, :exec, 'volt precompile'
      end

      with rails_env: fetch(:rails_env) do
        execute '$HOME/bin/unicorn_wrapper', 'restart'
      end
    end
  end

  after :publishing, :restart
end
