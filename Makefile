include .env
export

install_requirements:
	echo "Installing requirements..."
	sudo sh ./scripts/install_requirements.sh
	sudo usermod -aG docker echo $(shell whoami)
	echo "Requirements installed!"

prepare_images:
	echo "Preparing Docker Images..."
	docker build -f dockerfiles/Dockerfile.apache -t apache:satellite .
	docker pull mysql:5.7
	docker pull phpmyadmin/phpmyadmin:4.8.0
	echo "Docker images ready!"

generate_satellite:
	echo "Generating Satellite Website $(WEBSITE_NAME)"
	[ -z "${WEBSITE_NAME}" ] && echo "The env. variable WEBSITE_NAME must be set!" && exit 1 || echo "Creating folder for website $(WEBSITE_NAME)..."
	[ -d "$(WEBSITE_NAME)" ] && echo "Folder already exists, select a different website Name." && exit 1 || echo "Creating folder..."
	mkdir -p $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website
	mkdir $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/certs
	mkdir $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/database

	echo "Copying required files..."
	cp resources/Template.docker-compose.yml $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/docker-compose.yml
	cp resources/satellite-$(SATELLITE_VERSION).tgz $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website/satellite.tgz
	cp -r scripts $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/scripts

	echo "Extracting files..."
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && tar xvf satellite.tgz --strip 1 && rm satellite.tgz
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && cp sites/default/default.settings.php sites/default/settings.php
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && mkdir sites/default/files
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && chgrp -R www-data sites/default/files
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && chmod -R g+rwx sites/default/files
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && chgrp www-data sites/default/settings.php
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && chmod g+rwx sites/default/settings.php

	echo "Set permissions..."
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME) && chgrp www-data scripts
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME) && chmod g+rwx scripts

	echo "Set website domain..."
	read -p "Website domain (URL): " WEBSITE_DOMAIN; sed -i "s/<insert_website_domain>/$$WEBSITE_DOMAIN/g" $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/docker-compose.yml

start_satellite:
	[ -z "${WEBSITE_NAME}" ] && echo "The env. variable WEBSITE_NAME must be set!" && exit 1 || echo "Starting Website: $(WEBSITE_NAME)..."
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME) && docker-compose up -d

create_certificate:
	[ -z "${WEBSITE_NAME}" ] && echo "The env. variable WEBSITE_NAME must be set!" && exit 1 || echo "Creating certificates for Website: $(WEBSITE_NAME)..."
	docker exec -it $(shell echo $(WEBSITE_NAME) | tr A-Z a-z)_web_1 bash /scripts/create_certificates.sh
	echo "Creating cron job for automatic renewal..."
	-crontab -l > tmp.cron
	echo "* * 1 * * docker exec $(shell echo $(WEBSITE_NAME) | tr A-Z a-z)_web_1 bash /scripts/renew_certificates.sh >> /home/wpa/satellite-docker/cron.log 2>&1" >> tmp.cron
	crontab tmp.cron
	rm tmp.cron

renew_certificates:
	[ -z "${WEBSITE_NAME}" ] && echo "The env. variable WEBSITE_NAME must be set!" && exit 1 || echo "Renewing certificates of Website: $(WEBSITE_NAME)..."
	docker exec -it $(shell echo $(WEBSITE_NAME) | tr A-Z a-z)_web_1 bash /scripts/renew_certificates.sh

recreate_certificates:
	[ -z "${WEBSITE_NAME}" ] && echo "The env. variable WEBSITE_NAME must be set!" && exit 1 || echo "Recreating certificates of Website: $(WEBSITE_NAME)..."
	docker exec -it $(shell echo $(WEBSITE_NAME) | tr A-Z a-z)_web_1 bash /scripts/recreate_certificate.sh


stop_satellite:
	[ -z "${WEBSITE_NAME}" ] && echo "The env. variable WEBSITE_NAME must be set!" && exit 1 || echo "Stopping Website: $(WEBSITE_NAME)..."
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME) && docker-compose down

restart_satellite:
	[ -z "${WEBSITE_NAME}" ] && echo "The env. variable WEBSITE_NAME must be set!" && exit 1 || echo "Checking website $(WEBSITE_NAME)..."
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME) && docker-compose restart

fix_permissions:
	echo "Fixing permission on Satellite Website $(WEBSITE_NAME)"
	[ -z "${WEBSITE_NAME}" ] && echo "The env. variable WEBSITE_NAME must be set!" && exit 1 || echo "Fixing permissions of website $(WEBSITE_NAME)..."
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && chgrp -R wpa sites
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && chgrp -R www-data sites/default/files
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && chmod -R g+rwx sites/default/files
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && chgrp www-data sites/default/settings.php
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME)/website && chmod g+rwx sites/default/settings.php
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME) && chgrp www-data scripts
	cd $(WEBSITES_FOLDER)/$(WEBSITE_NAME) && chmod g+rwx scripts
