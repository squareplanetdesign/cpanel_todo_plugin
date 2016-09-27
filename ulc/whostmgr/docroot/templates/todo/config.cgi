#!/usr/bin/perl

package config::cgi;

use lib '../../../';

use Cpanel::Plugins::Cpanel::CGI::JSON::Config ();

__PACKAGE__->run( @ARGV ) unless caller();

sub run {
    Cpanel::Plugins::Cpanel::CGI::JSON::Config::run(@_);
}

__END__

