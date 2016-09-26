cd /usr/local/cpanel/whostmgr/docroot/templates/

mkdir plugins
cd plugins
mkdir cpanel
cd plugins

ln -s /var/cpanel/plugins/cpanel/todo/ulc/whostmgr/docroot/templates/todo todo

cd /usr/local/cpanel/base/frontend/paper_lantern/

mkdir plugins
cd plugins
mkdir cpanel
cd plugins

ln -s /var/cpanel/plugins/cpanel/todo/ulc/base/frontend/paper_lantern/todo todo

cd /usr/local/cpanel/Cpanel/API/

ln -s /var/cpanel/plugins/cpanel/todo/ulc/Cpanel/API/Todo.pm Todo.pm