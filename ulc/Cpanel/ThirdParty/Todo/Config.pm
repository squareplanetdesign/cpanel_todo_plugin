package Cpanel::ThirdParty::Todo::Config;

use Carp        ();
use File::Slurp ();
use File::Copy  ();
use JSON        ();

our $FILE_NAME = 'config.json';
our $FILE_PATH = "/var/cpanel/thirdparty/todo";

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    $self->init();
    return $self;
}

sub init {
    my $self = shift;

    $self->{path} = "$FILE_PATH/$FILE_NAME";
    $self->{is_loaded}       = 0;
    $self->{is_changed}      = 0;

    if (!-e $self->{path}) {
        $self->{config} = $self->_default();
        $self->{is_loaded}  = 1;
        $self->{is_changed} = 1;
    }
    else {
        $self->load();
    }
}

sub _default {
    my $self = shift;
    return {
        whm => {
            enabled => JSON::true,
        },
        cpanel => {
            enabled => JSON::true,
        },
        webmail => {
            enabled => JSON::true,
        },
    };
}

sub load {
    my $self = shift;

    my $config_json = eval { File::Slurp::read_file($self->{path}, { atomic => 1 }) };
    if (my $exception = $@) {
        Carp::croak("Unable to load the config file, $self->{path}, with error: $exception");
    }

    $self->{config} = eval { JSON->new->pretty->decode($config_json) };
    if (my $exception = $@) {
        die "Config if improperly formatted. Issue: $exception";
    }
    $self->{is_loaded}  = 1;
    $self->{is_changed} = 0;
}

sub save {
    my $self = shift;

    if ($self->{is_changed}) {
        my $config_json = JSON->new->pretty->encode($self->{config});

        eval { File::Slurp::write_file($self->{path}, { atomic => 1, pretty => 1 }, $config_json) };
        if (my $exception = $@) {
            Carp::croak("Unable to save the config file, $self->{path}, with error: $exception");
        }

        $self->{is_loaded}       = 1;
        $self->{is_changed}      = 0;
    }
}

sub param {
    my $self = shift;
    my ($name, $value) = @_;
    my $read_write = (@_ == 2) ? 1 : 0;
    my @path = split /[.]/, $name;

    my $ref = $self->{config};
    for( my $i = 0, $l = @path; $i < $l; $i++) {
        my $key = $path[$i];
        if (   !defined $ref->{$key}  # Not exists
            && $i < $l - 1) {        # Not the last one

            # Create an empty hash
            # so we can continue
            $ref->{$key} = {};
            $self->{is_changed} = 1;
        }

        if ($i < $l - 1) {
            $ref = $ref->{$key};
        }
    }

    if ($read_write) {
        $ref->{$path[-1]} = $value;
        $self->{is_changed} = 1;
    }
    return $ref->{$path[-1]};
}

sub is_loaded {
    my $self = shift;
    return $self->{is_loaded};
}

sub is_changed {
    my $self = shift;
    return $self->{is_changed};
}

1;
