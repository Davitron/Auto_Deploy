#! /bin/bash

# install nodejs via nvm

setupNode() {
  printf '\n ************************************** Installing NODEJS **************************************** \n'
  sudo apt-get update
  curl -sL https://deb.nodesource.com/setup_9.x -o nodesource_setup.sh
  sudo bash nodesource_setup.sh
  sudo apt-get install nodejs -y
}

declareEnv() {
#   sudo bash -c 'cat > .env <<EOF
#   export NODE_ENV=production
#   export DATABASE_URL=<POSTGRESQL DATABASE URL>
#   export SECRET_KEY=<JWT SECRET>
#   export EMAIL_ADDRESS=<MAILING SERVICE EMAIL ADDRESS>
#   export EMAIL_PASSWORD=<MAILING SERVICE PASSWORD>
# EOF'
  source ../env
}

# clone application repository
cloneRepo() {
  printf '\n ************************************** Cloning Repository From Github **************************** \n'
  if [ -d EventsManagerApp ]; then
    rm -rf EventsManagerApp
    git clone -b aws-deploy https://github.com/Davitron/EventsManagerApp.git
  else
    git clone -b aws-deploy https://github.com/Davitron/EventsManagerApp.git
  fi
}

buildDependencies() {
  cd EventsManagerApp
  printf '\n ********************************* Installing All Dependencies ******************************************* \n'
  sudo npm install -g sequelize-cli
  npm install
  printf '\n *************************************** Building Application ******************************************** \n'
  npm run build:server
  npm run load-config
  npm run load-swagger
}

configureNGINX() {
    printf '\n ************************************ Configuring NGINX ********************************************** \n'
    sudo apt-get install nginx -y
    sudo rm -rf /etc/nginx/sites-enabled/default
    if [[ -f /etc/nginx/sites-enabled/eventManager ]]; then
        printf '\n ******************************** Removing Existing Configurations ******************************* \n'
        sudo rm -rf /etc/nginx/sites-enabled/eventManager
        sudo rm -rf /etc/nginx/sites-available/eventManager
    fi
    sudo bash -c 'cat > /etc/nginx/sites-available/eventManager <<EOF
    server {
        listen 80;
        server_name example.com www.example.com;
        location / {
            proxy_pass 'http://127.0.0.1:8000';
        }
    }'
    sudo ln -s /etc/nginx/sites-available/eventManager /etc/nginx/sites-enabled/eventManager
    sudo service nginx restart
}

configureSSL() {
  printf '\n ****************************************** Configuring SSL ******************************************* \n'
  sudo apt-get update
  sudo apt-get install software-properties-common
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt-get update
  sudo apt-get install python-certbot-nginx -y
  sudo certbot --nginx
}

configureProcessManager() {
  printf '\n ************************************** Running Database Migration *************************************** \n'
  sequelize db:migrate:undo:all
  sequelize db:migrate
  sequelize db:seed:all
	printf '\n ****************************************** Installing PM2 ******************************************* \n'
	sudo npm install -g pm2
	pm2 start npm -- start
}

main() {
  cloneRepo
	setupNode
  configureNGINX
  configureSSL
  buildDependencies
  declareEnv
	configureProcessManager
}

main