Nginx Setup
---
- `ssh root@162.243.245.217` - *need to enter password for root*
- `sudo apt-get update`
- `sudo apt-get upgrade -y ` - *install without asking user if to continue*
- `sudo apt-get install curl vim build-essential python-software-properties git-core`
- `addgroup admin`
- `adduser deployer --ingroup admin`
- `ssh-copy-id deployer@162.243.245.217` - *run from local terminal, not on the server*
- `sudo add-apt-repository ppa:nginx/stable`
- `sudo apt-get update`
- `sudo apt-get install nginx`
- `cd /etc/nginx/sites_enabled`
- `vim default`
- `cd /usr/share/nginx/html`
- `cat index.html`

Configuring Nginx
---
- First configure domains (point them to the server) in DNS section of DigitalOcean cloud infrastructure. For example `cheqin.me`, `cloudscri.be` or `devops.be`
- `ssh deployer@162.243.245.217`
- `cd /opt`
- `sudo mkdir www`
- `sudo chgrp -R admin www` - *means new 'www' folder should be owned by admin group*
- `sudo chmod -R g+rwxs www` - *set permissions to read/write/execute files in the folder*
- `cd www`
- `mkdir devops.be` - *no need for sudo because our user belongs to admin group and we set permissions for that group*
- `cd devops.be`
- `vim index.html`

##### Content of index.html

> \<!doctype html\><br>
> \<html lang="en"\><br>
> \<head\><br>
> \<title\>Welcome to devops.be\</title\><br>
> \</head\><br>
> \<body\><br>
> \<h1\>Devops.be!\</h1\><br>
> \</body\><br>
> \</html\>

- `cd /etc/nginx/sites-available`
- `sudo vim devops.be`

##### Content of devops.be

> server {<br>
    &nbsp;&nbsp;listen 80;<br>
    &nbsp;&nbsp;server_name devops.be;<br>
    &nbsp;&nbsp;return 301 $scheme://www.devops.be$request_uri;<br>
  }
  
> server {<br>
    &nbsp;&nbsp;listen 80;<br>
    &nbsp;&nbsp;server_name www.devops.be;<br>
    &nbsp;&nbsp;access_log /opt/www/devops.be/access.log;<br>
    &nbsp;&nbsp;root /opt/www/devops.be;<br>
  }

- `cd ../sites-enabled`
- `sudo ln -s /etc/nginx/sites-available/devops.be devops.be` - *create symbolic link*
- `sudo service nginx restart` - *in real world it is better to use `reload`*
- `cd /var/log/nginx` - *in case the server didn't start we probably have an error in config. How to debug?*
- `tail -f error.log` - *global nginx log*

Git Deployment
---
- `ssh deployer@162.243.245.217`
- `mkdir devopsbe.git`
- `cd devopsbe.git`
- `git init --bare` - *intialize current folder as .git folder with all that ususally comes with that*
- `cd hooks`
- `touch post-receive`
- `vim post-receive`

##### Content of post-receive

> export GIT_WORK_TREE=/opt/www/devops.be<br>
  git checkout -f master
  
- `chmod +x post-receive` - *make the file executable*
- `exit`
- `cd Work/devops-lab` - *here and after all commands executed on local machine*
- `mkdir devopsbe`
- `cd devopsbe`
- `git init`
- `subl .` - *open Sublime Text or any other editor and create index.html*

##### Content of index.html
  
> \<!DOCTYPE html\><br>
  \<html\><br>
  &nbsp;&nbsp;\<head\><br>
  &nbsp;&nbsp;&nbsp;&nbsp;\<title\>DevOps.be!\</title\><br>
  &nbsp;&nbsp;\</head\><br>
  &nbsp;&nbsp;\<body\><br>
  &nbsp;&nbsp;&nbsp;&nbsp;\<h1\>Welcome to Devopsbe\</h1\><br>
  &nbsp;&nbsp;&nbsp;&nbsp;\<p\>YAY update via git hook!\<p\><br>
  &nbsp;&nbsp;\</body\><br>
  \</html\>
  
- `git status`
- `git add .`
- `git commit -am "initial index.html"`
- `git remote add production deployer@162.243.245.217:devopsbe.git`
- `git remote -v` - *a sanity test to see it was configured as expected*
- `git push production master`

The Database
---
- `ssh deployer@162.243.245.217`
- `cd /etc/apt/sources.list.d`
- `sudo vim pgdg.list` - *wiki.postgresql.org/wiki/apt*

##### Content of pgdg.list

> deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main

- `wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -`
- `cd`
- `sudo apt-get update`
- `sudo apt-get install postgresql-9.3 postgresql-contrib-9.3 libpq-dev -y`
- `sudo-u postgres psql`

##### Inside psql command line

- `create user deployer;` - *for security reasons we may create db user with name other than user for VM connection for example `deployer_db_user` or `deployer_<random number>`*
- `alter user deployer with superuser;` - *grand superuser rights for deployer it cold be useful in Rails migrations*
- `alter user deployer with password '<use some strong password generator service>'` - *save a password or hint somewhere, for example email it to yourself*
- `create database shopper_production with owner deployer;`
- `\q`

Installing Ruby
---
- `ssh deployer@162.243.245.217`
- `cd /usr/local`
- `sudo git clone git://github.com/sstephenson/rbenv.git rbenv` - *http://blakewilliams.me/posts/4-system-wide-rbenv-install*
- `sudo chgrp -R admin rbenv`
- `sudo chmod -R g+rwxXs rbenv`
- `sudo vim /etc/skel/.profile`

##### Content of .profile

> ...<br>
  export RBENV_ROOT=/usr/local/rbenv<br>
  export PATH="$RBENV_ROOT/bin:$PATH"<br>
  eval "$(rbenv init -)"

- `vim ~/.profile`

##### Content of .profile

> ...<br>
  export RBENV_ROOT=/usr/local/rbenv<br>
  export PATH="$RBENV_ROOT/bin:$PATH"<br>
  eval "$(rbenv init -)"

- `. ~/.profile`
- `rbenv`
- `cd rbenv`
- `mkdir plugins`
- `cd plugins`
- `git clone git://github.com/sstephenson/ruby-build.git`
- `cd`
- `rbenv install --list`
- `rbenv install 2.0.0-p353`
- `rbenv global 2.0.0-p353`
- `ruby -v` - *check that rbenv indeed set ruby version as expected*
