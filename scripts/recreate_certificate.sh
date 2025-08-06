#!/bin/bash

[ -z "$WEBSITE_DOMAIN" ] && echo "The env. variable WEBSITE_DOMAIN must be set!" && exit 1 || echo "Got website domain: $WEBSITE_DOMAIN..."
certbot revoke --cert-name $WEBSITE_DOMAIN

rm /etc/apache2/sites-available/000-default-le-ssl.conf
rm /etc/apache2/sites-enabled/000-default-le-ssl.conf

certbot --apache -d $WEBSITE_DOMAIN -m wpa@esnportugal.org --agree-tos --redirect -n
