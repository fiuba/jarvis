Deploy
======

1. Install RVM (might need to install _curl_ first):

    ```\curl -sSL https://get.rvm.io | bash```
1. Install and use jarvis ruby version (currently 1.9.3-p429):

    ```
    rvm install ruby-1.9.3-p429
    rvm use ruby-1.9.3-p429
    ```
1. Install god gem:

    ```gem install god```
1. Create jarvis gemset:

    ```rvm gemset create jarvis```
1. Create RVM wrapper for god:

    ```rvm wrapper ruby-1.9.3-p429@jarvis bootup god```
    (ref: https://rvm.io/deployment/god)
1. Update the init script for god, replacing the ```<RVM install dir>``` placeholder with the path to the directory where you installed RVM (i.e.: /home/vagrant/.rvm)
1. Create the global directory where god config files will live:

    ```sudo mkdir /etc/god/```
1. Copy the global god config file to reference the new directory:

    ```cp extras/god.conf /etc/god.conf```
1. Copy init script for god from extras dir and make it executable

    ```
    sudo cp extras/god /etc/init.d/god
    sudo chmod +x /etc/init.d/god
    ```
1. Create a symlink for the ```jarvis.god``` file to the global god config dir:

    ```ln -s jarvis.god /etc/god```
1. Run god:
    ```sudo /etc/init.d/god start```