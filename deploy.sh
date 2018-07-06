#! /bin/bash

# install nodejs via nvm

setupNode() {
  printf '******************************************** Installing NVM *********************************************** \n'
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  source ~/.profile

  printf '******************************************** Installing NODE VERSION 9.11.1 *********************************************** \n'
  nvm install v9.11.1
  export NODE_ENV=production
  printf '******************************************** NODE SETUP SUCCESSFUL *********************************************** \n'
}


# clone application repository
cloneRepo() {
  printf '*************************************** CLONE GIT REPOSITORY FROM GITHUB *********************************************** \n'
  if [ -d EventsManagerApp ]; then
    rm -rf EventsManagerApp
    git clone https://github.com/Davitron/EventsManagerApp.git 
  else
    git clone https://github.com/Davitron/EventsManagerApp.git
  fi
}

#setup application
# install dependencies and build the application

defineEnvVariables() {
  sudo bash -c 'cat > ./.env <<-EOF
  DATABASE_URL=postgres://postgres:posgres:postgres@ec2-18-219-31-108.us-eact-2.compute.amazinaws.com:5432/event-manager?sss=true
  SECTRET_KEY=topsecret
  EMAIL_ADDRESS=matthews.segunapp@gmail.com
  EMAIL_PASSWORD=holly213
	EOF'
}

buildApplication() {
  printf '******************************************** Installing All Dependencies ****************************************************** \n'
  cd EventsManagerApp
  npm install
  npm run full-build
  defineEnvVariables
}

configureNGINX() {
	printf '******************************************** Configuring NGINX ****************************************************** \n'
	sudo apt-get update
	sudo apt-get install nginx -y
	sudo rm -rf /etc/nginx/sites-enabled/default
	if [[ -f /etc/nginx/sites-enabled/eventManager ]]; then
		printf '****************************************** Found Existing Configuration ******************************************* \n'
		sudo rm -rf /etc/nginx/sites-enabled/eventManager
		sudo rm -rf /etc/nginx/sites-available/eventManager
	fi
	sudo bash -c 'cat > /etc/nginx/sites-available/eventManager <<-EOF
	server {
		listen 80;
		server_name EventManager;
		location / {
			proxy_pass 'http://127.0.0.1:8000';
		}
	}
	EOF'
	sudo ln -s /etc/nginx/sites-available/eventManager /etc/nginx/sites-enabled/eventManager
	sudo service nginx restart
}

configureProcessManager() {
	printf '****************************************** Installing PM2 ******************************************* \n'
	npm install -g pm2
	printf '****************************************** Run Database Migration ******************************************* \n'
	npm run db:migration
	pm2 start npm -- start

}

deploy() {
	setupNode
	cloneRepo
	buildApplication
	configureNGINX
	configureProcessManager
}

deploy