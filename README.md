# Create an environment for Drupal development that includes nginx, MariaDB and PHP.

## Basic Usage

1. Clone this repo into your desired projects folder (e.g. ~/sites) and change
the repo name to the desired project name:

```sh
cd ~/sites
git clone https://github.com/omegamonk/vagrant-drupal-dev
mv vagrant-drupal-dev project_name.dev
```

2. Next build your stub site by executing the build shell script and going
  through the prompts. Note the site.make file is created on the assumption that
  you will develop using an install profile. If you prefer not to, then simply
  don’t build the site.make and instead extract your site to **project_name.dev/site-root/**

```sh
cd project_name.dev
./build.sh
```

Remember to update /etc/hosts so your desired project domain name points to the
IP address in Vagrantfile.

3. Create the virtual machine:

```sh
vagrant up
```

## Connection with SQL Client
A mariadb user root@192.168.% is created by default (no password). As long as
you set the IP address of your VM to 192.168.*, then you should be able to
perform a standard connection by setting your client's 'host' field to this
address with 'user' as root.

## Start mailcatcher

vagrant ssh into your vm, and run

```sh
mailcatcher --ip=0.0.0.0
```

 Mail sent with Drupal will now be caught, and you can view them in your browser
 at **project_domain:1080**