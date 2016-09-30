# NOTE: This is not complete yet
# TODO: Make it more robust
# TODO: Add prerequsites.
# TODO: Make this suitable for a real plugin.

# Only needed to get the tests to perl run
#/usr/local/cpanel/3rdparty/perl/522/bin/cpan Test::MockTime
#/usr/local/cpanel/3rdparty/perl/522/bin/cpan URL::Encode

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
mkdir Cpanel
cd Cpanel

ln -s /var/cpanel/plugins/cpanel/todo/ulc/Cpanel/Plugins/Cpanel/Todo Todo