#!/bin/bash
service cron start

touch /var/www/magento2/var/.setup_cronjob_status /var/www/magento2/var/.update_cronjob_status
chown app:app /var/magento2/html/var/.setup_cronjob_status /var/www/magento2/var/.update_cronjob_status

/usr/bin/crontab