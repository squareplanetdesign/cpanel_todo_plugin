package Cpanel::ThirdParty::CGI::JSON::Config;

use strict;
use warnings;

use parent qw(Cpanel::ThirdParty::CGI::JSON::Base);

use Cpanel                           ();
use JSON                             ();
use Cpanel::ThirdParty::Todo::Config ();
use Whostmgr::ACLS                   ();

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->SUPER::init(@_);
    $self->init();
    return $self;
}

sub init {
    my $self = shift;
    $self->{config} = undef;
}

sub config_manager {
    my $self = shift;
    if (!$self->{config}) {
        $self->{config} = Cpanel::ThirdParty::Todo::Config->new();
    }
    return $self->{config};
}

sub run {
    my $self = shift;

    if (!Whostmgr::ACLS::hasroot()) {
        return $self->unauthorized('Must be root to run configure todo access.');
    }

    my $config_manager = eval { $self->config_manager() };
    if( my $exception = $@ ) {
        return $self->server_error("Failed to load the configuration with exception: $exception.");
    }
    if (!$config_manager || !$config_manager->is_loaded()) {
        return $self->server_error("Failed to load the configuration.");
    }

    my $method = $self->method();
    if( $method eq 'GET' ) {
        return $self->get_config();
    }
    elsif( $method eq 'SET') {
        return $self->update_config();
    }
    else {
        return $self->method_not_allowed();
    }
}

sub get_config {
    my $self = shift;
    my $out = '';

    my $json = eval { JSON->new->pretty->encode($self->config_manager()->config()) };
    if( my $exception = $@ ) {
        return $self->bad_request("Could not encode the configuration as JSON in the GET request with exception: $exception");
    }

    if (!$json) {
        return $self->server_error("Configuration not found in request.");
    }

    return $self->success($json);
}

sub update_config {
    my $self = shift;
    my $json = $self->page()->param('JSON');
    if(!$json) {
        return $self->bad_request("No JSON body sent with the request.");
    }

    my $config_manager = $self->config_manager();

    eval { $config_manager->load_json($json) };
    if( my $exception = $@) {
        return $self->bad_request("Could not load the JSON data in the PUT with exception: $exception")
    }

    eval { $config_manager->save() };
    if( my $exception = $@) {
        return $self->server_error("Failed to save the configuration with exception: $exception")
    }

    return $self->get_config();
}


1;
