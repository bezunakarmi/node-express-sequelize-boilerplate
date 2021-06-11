# Application #
#####################################################################################
set :application,     'node-boiler-plate'
set :branch,          ENV["branch"] || "master"
set :user,            ENV["user"] || ENV["USER"] || "boiler-plate"


# SCM #
#####################################################################################
set :repo_url,        'git@gitlab.com:ruchidhami/node-boiler-plate.git'
set :repo_base_url,   :'http://gitlab.com'
set :repo_diff_path,  :'node-boiler-plate/compare/master...'
set :repo_branch_path,:'node-boiler-plate/tree'
set :repo_commit_path,:'node-boiler-plate/commit'


# Multistage Deployment #
#####################################################################################
set :stages,              %w(dev staging prod)
set :default_stage,       "staging"


# Other Options #
#####################################################################################
set :ssh_options,         { :forward_agent => true }
set :default_run_options, { :pty => true }


# Permissions #
#####################################################################################
set :use_sudo,            false
set :permission_method,   :acl
set :use_set_permissions, true
set :webserver_user,      "www-data"
set :group,               "www-data"
set :keep_releases,       2


# Set current time #
#######################################################################################
require 'date'
set :current_time, DateTime.now
set :current_timestamp, DateTime.now.to_time.to_i

# Rollbar #
#######################################################################################
set :rollbar_token, ''
set :rollbar_env, Proc.new { fetch :stage }
set :rollbar_role, Proc.new { :app }



# Setup Tasks #
#######################################################################################
namespace :setup do
    desc "Create overlay folders"
    task :create_overlay_folder do
        on roles(:all) do
            puts ("--> Creating overlay folders")
            execute "mkdir -p #{fetch(:overlay_path)}"
        end
    end

    desc "Create uploads dirs"
    task :create_upload_dir do
        on roles(:all) do
            puts ("--> Create uploads dirs")
            execute "mkdir -p #{shared_path}/uploads"
        end
    end

    desc "Set up project"
    task :init do
        on roles(:all) do
            puts ("--> Setting up project")
            invoke "setup:create_overlay_folder"
        end
    end
end


# DevOps Tasks #
#######################################################################################
namespace :devops do
    desc "Run database migrate task."
    task :migrate do
        on roles(:app) do
            within release_path.join("") do
                puts ("--> Running database migrate task.")
                execute :sequelize, "db:migrate"
            end
        end
    end

    desc "Copy Parameter File(s)"
    task :copy_parameters do
        on roles(:all) do |host|
            puts ("--> Copying Parameter File(s)")
            upload! "./config/deploy/parameters/#{fetch(:env)}/parametersServer.sed", "#{fetch(:overlay_path)}/parametersServer.sed"

        end
    end

    desc "Copy ecosystem.json file"
    task :copy_pm2_ecosystem do
        on roles(:all) do |host|
            puts ("--> Copying ecosystem.json file")
            upload! "./config/deploy/parameters/#{fetch(:env)}/ecosystem.json", "#{fetch(:overlay_path)}/ecosystem.json"
        end
    end

    desc 'Reload nginx server'
    task :nginx_reload do
        on roles(:all) do
            execute :sudo, :service, "nginx reload"
        end
    end

    desc "Start PM2"
    task :pm2_start do
        on roles(:all) do
            within release_path do
                puts ("--> Starting PM2")
                execute :pm2, "start server/build/server.js --name #{fetch(:pm2_app_name)}"
            end
        end
    end

    desc "Stop PM2"
    task :pm2_stop do
        on roles(:all) do
            within release_path do
                puts ("--> Stopping PM2")
                execute :pm2, "stop --silent #{fetch(:pm2_app_name)}"
            end
        end
    end

    desc "Restart PM2"
    task :pm2_restart do
        on roles(:all) do
            within release_path do
                puts ("--> Restarting PM2")
                execute :pm2, "restart --silent #{fetch(:pm2_app_name)}"
            end
        end
    end

    desc "Hot reload PM2"
    task :pm2_reload do
        on roles(:all) do
            within release_path do
                puts ("--> Hot reloading PM2")
                execute :pm2, "reload --silent #{fetch(:pm2_app_name)}"
            end
        end
    end

    desc "Start or reload pm2"
    task :pm2_start_or_reload_ecosystem do
        on roles(:all) do
            within fetch(:overlay_path) do
                puts ("--> Starting or reloading PM2")
                execute :pm2, "startOrReload #{fetch(:overlay_path)}/ecosystem.json"
            end
        end
    end
end


# Installation Tasks #
#######################################################################################
namespace :installation do
    desc 'Copy node_modules directory from last release'
    task :node_modules_copy do
        on roles(:web) do
            puts ("--> Copying node_modules into directory from previous release")
            execute "vendorDir=#{current_path}/node_modules; if [ -d $vendorDir ] || [ -h $vendorDir ]; then cp -a $vendorDir #{release_path}/server/node_modules; fi;"
        end
    end

    desc "Running Npm Install"
    task :npm_install do
        on roles(:app) do
            within release_path do
                puts ("--> Installing npm packages in directory")
               #execute("cd #{release_path} && npm install")
                execute :yarn
            end
        end
    end

    desc "Set environment variables"
    task :set_env_variables do
        on roles(:app) do

              puts ("--> Copying environment configuration file")
              execute "cp #{release_path}/.env.server #{release_path}/.env"

              puts ("--> Setting environment variables")
              execute "sed --in-place -f #{fetch(:overlay_path)}/parametersServer.sed #{release_path}/.env"
        end
    end


    desc "Create ver.txt"
    task :create_ver_txt do
        on roles(:all) do
            puts ("--> Copying ver.txt file")
            execute "cp #{release_path}/config/deploy/ver.txt.example #{release_path}/client/build/ver.txt"
            execute "sed --in-place 's|%date%|#{fetch(:current_time)}|g
                        s|%branch%|#{fetch(:branch)}|g
                        s|%revision%|#{fetch(:current_revision)}|g
                        s|%deployed_by%|#{fetch(:user)}|g' #{release_path}/client/build/ver.txt"
            execute "find #{release_path} -type f -name 'ver.txt' -exec chmod 664 {} \\;"
        end
    end
end

# Application specific Tasks #
#######################################################################################
namespace :application do
    desc "Build application"
    task :build do
        on roles(:all) do
            within release_path.join('client') do
                puts ("--> Building react app")
                execute :yarn, "add @babel/runtime@7.9.0"
                execute :yarn, "build"
            end

            # within release_path.join('server') do
            #     puts ("--> Building node app")
            #     execute :yarn, "build"
            # end
        end
    end
end


# Tasks Execution #
#######################################################################################

desc "Setup Initialize"
task :setup_init do
    invoke "setup:init"
    invoke "devops:copy_parameters"
    invoke "devops:copy_pm2_ecosystem"
end


desc "Update Environment File"
task :update_env do
    invoke "devops:copy_parameters"
    invoke "devops:copy_pm2_ecosystem"
    invoke "installation:set_env_variables"
    invoke "build_app"
end


desc "Build and restart app"
task :build_app do
    invoke "application:build"
    invoke "devops:pm2_start_or_reload_ecosystem"
end


desc "Deploy Application"
namespace :deploy do
    after   :updated,   "installation:node_modules_copy"
    after   :updated,   "installation:npm_install"
    after   :updated,   "installation:set_env_variables"
    #after   :updated,   "application:build"
    #after   :finished,  "installation:create_ver_txt"
    #after   :finished,  "devops:migrate"
    # after   :finished,  "devops:seed"
end

after "deploy", "devops:pm2_start_or_reload_ecosystem"
