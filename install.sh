/usr/local/cpanel/3rdparty/perl/522/bin/cpan Test::MockTime
/usr/local/cpanel/3rdparty/perl/522/bin/cpan URL::Encode

# Setup the whm application
cd /usr/local/cpanel/whostmgr/docroot/templates/

mkdir plugins
cd plugins
mkdir cpanel
cd plugins

ln -s /var/cpanel/plugins/cpanel/todo/ulc/whostmgr/docroot/templates/todo todo

# Setup the whm application
cd /usr/local/cpanel/base/frontend/paper_lantern/

mkdir plugins
cd plugins
mkdir cpanel
cd plugins

ln -s /var/cpanel/plugins/cpanel/todo/ulc/base/frontend/paper_lantern/todo todo

# Setup the UAPI call
cd /usr/local/cpanel/Cpanel/API/

ln -s /var/cpanel/plugins/cpanel/todo/ulc/Cpanel/API/Todo.pm Todo.pm

# Setup the Perl Modules

cd /usr/local/cpanel/Cpanel
mkdir Plugins
cd Plugins

ln -s /var/cpanel/plugins/cpanel/todo/ulc/Cpanel/Plugins Todo