import os

def setup_webroot():

    command = "chgrp www-data webroot/sites/default/files/"
    os.system(command)
    
    command = "cp webroot/sites/default/default.settings.php webroot/sites/default/settings.php"
    os.system(command)
    
    command = "chmod g+rwxs webroot/sites/default/files"
    os.system(command)

    command = "chgrp www-data webroot/sites/default/settings.php"
    os.system(command)

    command = "chmod g+rwxs webroot/sites/default/settings.php"
    os.system(command)


def docker_up():
    print("[6/x] Starting the Docker container ...")
    command = "docker-compose up -d > /dev/null 2>&1"
    os.system(command)


def starting_message():
    print("\n   DockerizeSatellite   \n   Version 1.0 ")
    print("   Please run this script with high privileges or check the docs   \n")


def main():
    starting_message()
    setup_webroot()
    docker_up()
    print('[+] Satellite is running, your can access it at http://localhost')


if __name__ == '__main__':
    main()
