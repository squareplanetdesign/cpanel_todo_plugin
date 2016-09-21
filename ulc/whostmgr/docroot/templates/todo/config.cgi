#!/usr/bin/perl

package config::cgi;

use lib '../../../../';

use Cpanel::ThirdParty::CGI::JSON::Config ();

__PACKAGE__->run( @ARGV ) unless caller();

sub run {
    Cpanel::ThirdParty::CGI::JSON::Config::run(@_);
}

__END__

