#!/bin/bash

[ -z "$WEBSITE_DOMAIN" ] && echo "The env. variable WEBSITE_DOMAIN must be set!" && exit 1 || echo "Got website domain: $WEBSITE_DOMAIN..."
certbot --apache -d $WEBSITE_DOMAIN -m wpa@esnportugal.org --agree-tos --redirect -n
