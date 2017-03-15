# backup

Database and files backup script with logrotate and rclone.

## Installation
1. Add the package require 'widop/backup' to your `composer.json`
   ```    
       "require": {
           "widop/backup": "dev-develop"
       },
   ```
1. Add this post install script to your `composer.json` :
   ```
   "scripts": {
       "post-install-cmd": [
           "vendor/widop/backup/preinstall.sh"
       ]
   }
   ```
3. Run `composer install`, then fill-in asked parameters
