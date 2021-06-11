server '240.111.0.88',
user: 'boiler-plate',
roles: %w{web app},
port:22

set :env, 'production'
set :app_debug, 'false'
set :pm2_app_name, "node-boiler"

set :nvm_type, :user # or :system, depends on your nvm setup
set :nvm_node, 'v12.18.3'
set :nvm_map_bins, %w{node npm yarn pm2 sequelize}

# Directories #
#######################################################################################
set :deploy_to, '/home/boiler-plate/web'
set :shared_path, '/home/boiler-plate/web/shared'
set :overlay_path, '/home/boiler-plate/web/overlay'
set :tmp_dir, '/home/boiler-plate/web/tmp'