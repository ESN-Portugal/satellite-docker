## Satellite Dockerized

A working dockerized version of Satellite

**Current Version: 4.7.2**

Tested successfully on:
- Ubuntu 18.04.2 LTS

## Installation
The automated scripts in the current repository were developed with Ubuntu in mind.
Therefore, they might not work in different Operative Systems.

Clone the repository into your system and go into it:
```bash
git clone git@git.esn.org:portugal/satellite-docker.git
cd satellite-docker/
```

Install "Make" and "Git"
```bash
sudo apt install make
sudo apt install git
```

Install requirements
```bash
sudo make install_requirements
```

After running the previous recipe, make sure your user is in the "docker" group.
It is necesary to *log out* and *log in* for it to be updated.
```bash
groups
```

Prepare the Docker images
```bash
make prepare_images
```

Generate a Website
```bash
sudo make generate_satellite WEBSITE_NAME=<insert_here_the_name_of_your_satellite_website>
```
At the end of the generation step, you will be prompted to fill the domain of your website.
Please make sure it is correct. If it is wrongly set, delete the created folder and run this recipe again.

You are set!
Run your website!
```bash
make start_satellite WEBSITE_NAME=<insert_here_the_name_of_your_satellite_website>
```

See your running docker containers with:
```bash
docker ps
```

Do you want to stop or restart it?
```bash
make stop_satellite WEBSITE_NAME=<insert_here_the_name_of_your_satellite_website>
# or
make restart_satellite WEBSITE_NAME=<insert_here_the_name_of_your_satellite_website>
```

## Activate the HTTPS Certificate
```bash
make create_certificate WEBSITE_NAME=<insert_here_the_name_of_your_satellite_website>
```
This script will try to create a Let's Encrypt certificate.
If the configuration of the IP and domain is not correct, it might fail.

If suceeded, an automatic script to renew the certificate will be created.
You can check it with:
```bash
crontab -l
```

## Migrate an existing Satellite site
First of all, stop your running Docker containers:
```bash
make stop_satellite WEBSITE_NAME=<insert_here_the_name_of_your_satellite_website>
```

#### Database
- Open the port to access the PHPMYADMIN user interface
- Create a database and user with the same names and credentials as the one to be migrated
- In the newly empty created database, import the database to migrate


#### Files
- Copy your files over the new system
- Substitute the files in the "sites" folder with the ones from the site to be migrated
- Adapt the "settings.php" to match the new "database host" (It is by default "db")
- Run the script to fix permissions (*sudo make fix_permissions WEBSITE_NAME=<insert_your_website_name_here>*)

Start your Docker containers once more
```bash
make start_satellite WEBSITE_NAME=<insert_here_the_name_of_your_satellite_website>
```

## Useful Links

- [ESN Satellite](https://satellite.esn.org/)
- [Docker Installation](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- [Docker-Compose Installation](https://docs.docker.com/compose/install/)
- [Git](https://git-scm.com/)
 

## Typical issues

- Your user is not in the "docker" group
```bash
groups
```
- The IP of your server/machine is not set as "static"
- The "database host" in the "settings.php" of Drupal is not pointing to the "db" host of the database.
- The port of your PHPMYADMIN (default 8001) is closed. NOTE: it is important that you close it since it is not protected.
- If everything fails, just do a backup of your data, a clean installation and a migration of your data.
