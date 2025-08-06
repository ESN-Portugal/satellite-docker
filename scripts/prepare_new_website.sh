mkdir website
cp -r satellite/* website/
cp website/sites/default/default.settings.php website/sites/default/settings.php
mkdir website/sites/default/files
chmod -R g+rwx website/sites/default/files
chmod g+rwx website/sites/default/settings.php
