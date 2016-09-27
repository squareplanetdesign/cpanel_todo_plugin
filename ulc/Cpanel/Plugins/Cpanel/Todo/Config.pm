# Copyright (c) 2016, cPanel, Inc.
# All rights reserved.
# http://cpanel.net
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the owner nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package Cpanel::Plugins::Cpanel::Todo::Config;

use Carp        ();
use File::Slurp ();
use File::Copy  ();
use JSON        ();

our $FILE_NAME = 'config.json';
our $FILE_PATH = "/var/cpanel/plugins/cpanel/config/todo";

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

    if (!$self->_exists()) {
        $self->{config} = $self->_default();
        $self->{is_loaded}  = 1;
        $self->{is_changed} = 1;
    }
    else {
        $self->load();
    }
}

sub _exists {
    my $self = shift;
    return -e $self->{path} ? 1 : 0;
}

sub config {
    my $self = shift;
    return $self->{config};
}

sub _default {
    my $self = shift;
    return {
        whostmgrd => {
            enabled => JSON::true,
        },
        cpaneld => {
            enabled => JSON::true,
        },
        webmaild => {
            enabled => JSON::true,
        },
    };
}

sub load {
    my $self = shift;

    my $json = eval { File::Slurp::read_file($self->{path}, { atomic => 1 }) };
    if (my $exception = $@) {
        Carp::croak("Unable to load the config file, $self->{path}, with error: $exception");
    }

    return $self->load_json($json);
}

sub load_json {
    my ($self, $json) = @_;

    die "no configuration passed to load_json" if !$json;

    my $config = eval { JSON->new->pretty->decode($json) };
    if (my $exception = $@) {
        die "Configuration is improperly formatted. Issue: $exception";
    }

    $self->validate($config);

    $self->{config} = $config;
    $self->{is_loaded}  = 1;
    $self->{is_changed} = 0;
}

sub validate {
    my ($self, $config) = @_;

    die "no configuration passed to validate" if !$config;
    die "configuration not a hash" if ref $config ne 'HASH';

    my @unknown;
    foreach my $key (keys %$config) {
        die "configuration for $key is not a hash" if ref $config->{$key} ne 'HASH';
        @unknown = ();
        foreach my $subkey (keys %{$config->{$key}}) {
            push @unknown, "$key.$subkey" if grep { $_ ne $subkey } qw( enabled );
        }
        die "unrecognized keys in configuration: " . join(',', @unknown) if @unknown;

        foreach my $subkey (keys %{$config->{$key}}) {
            my $value = $config->{$key}{$subkey};
            die "$key.$subkey value $value is invalid."
              unless grep { $value == $_ } (0, 1, JSON::true, JSON::false);
        }
    }
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

# Persistence
sub TO_JSON {
    my $self = shift;
    return {
        %{ $self->{config} }
    };
}

1;
