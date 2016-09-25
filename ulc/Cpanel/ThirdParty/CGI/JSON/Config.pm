package Cpanel::ThirdParty::CGI::JSON::Config;

use parent qw(Cpanel::ThirdParty::CGI::JSON::Base);

use Cpanel                           ();
use JSON                             ();
use Cpanel::ThirdParty::Todo::Config ();

sub run {
    my $self = shift;

    my $method = $ENV{ 'REQUEST_METHOD' };

    if (!Cpanel::isroot()) {
        return $self->unauthorized('Must be root to run configure todo access.');
    }

    my $config_manager = eval { Cpanel::ThirdParty::Todo::Config->new() };
    if (!$config_manager->is_loaded()) {
        return $self->server_error();
    }

    if( $method eq 'GET' ) {
        _print $self->page()->header('application/json');
        my $json = eval { JSON::encode_json($config_manager->config()) };
        _print $json;
    }
    elsif( $method eq 'PUT') {
        my $raw_data = $self->page()->param('PUTDATA');
        if($raw_data) {
            return $self->bad_request();
        }

        my $data = eval { JSON::decode_json($raw_data) };
        if( my $exception = $@) {
            return $self->bad_request("Could not parse the JSON data in the PUT.")
        }
    }
    else {
        return $self->bad_request("Unsupported operation '$method'.");
    }
}

1;
