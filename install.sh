# TODO: Make this suitable for a real plugin.
# NOTE: This is not yet setup to work with the plugin
# installer, but could be easily adapted to that purpose.

# Only needed to get the tests to perl run
#/usr/local/cpanel/3rdparty/perl/522/bin/cpan Test::MockTime
#/usr/local/cpanel/3rdparty/perl/522/bin/cpan URL::Encode

CWD=$(pwd)
ULC=/usr/local/cpanel
INSTALL=/var/cpanel/plugins
PLUGIN_NAME=todo
PLUGIN=plugins/cpanel/$PLUGIN_NAME
PAPER_LANTERN=$ULC/base/frontend/paper_lantern

# Setup the whm application
cd $PAPER_LANTERN
mkdir -p plugins/cpanel

ln -s $INSTALL/$PLUGIN/ulc/base/frontend/paper_lantern/todo todo

# Setup the UAPI call
cd $ULC/Cpanel/API/

ln -s $INSTALL/$PLUGIN/ulc/Cpanel/API/Todo.pm Todo.pm

# Setup the Perl Modules
cd $ULC/Cpanel
mkdir -p Plugins/Cpanel
cd Plugins/Cpanel

ln -s $INSTALL/$PLUGIN/ulc/Cpanel/Plugins/Cpanel/Todo Todo

# Install the language packs
cd $ULC
mkdir -p modules-install/$PLUGIN_NAME
cd modules-install/$PLUGIN_NAME
ln -s $INSTALL/$PLUGIN/locale/ locale

cd $ULC
bin/build_locale_databases

cd $CWD