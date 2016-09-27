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
#
package Cpanel::Plugins::Cpanel::Todo::Item;

use Carp ();

our %STATUS = (
    todo => 1,
    done => 2,
);

our %STATUS_REVERSE = (
    1 => 'todo',
    2 => 'done',
);

our %STATUS_TEXT = (
    todo => 'TODO',
    done => 'Done',
);

# Validation method lookup
my $validators = {
    id          => \&_validate_integer,
    created     => \&_validate_datetime,
    updated     => \&_validate_datetime,
    doned       => \&_validate_datetime,
    status      => \&_validate_status,
    subject     => \&_validate_string,
    description => \&_validate_string,
};

# Dependency update method lookup
my $update = {
    status => \&_updated_status,
};

sub new {
    my ($class, %opts) = @_;

    my $now =  time();
    my $self = bless {
        id          => 0,
        subject     => '',
        created     => $now,
        updated     => $now,
        doned       => undef,
        description => '',
        status      => $STATUS{todo},
    }, $class;

    $self->init(%opts);

    return  $self;
}

sub init {
    my ($self, %opts) = @_;
    for my $key (qw/id subject description status created updated doned/) {
        if (defined $opts{$key}) {
            if (my $validate_fn = $validators->{$key}) {
                &$validate_fn($opts{$key}, $key);
            }

            # Update the value
            $self->{$key} = $opts{$key};

            # Update the dependencies if any
            if (my $update_fn = $update->{$key}) {
                &$update_fn($self, %opts);
            }

            $changed = 1;
        }
    }
}

sub id {
    my ($self, $value) = @_;
    return $self->{id};
}

sub created {
    my ($self, $value) = @_;
    return $self->{created};
}

sub updated {
    my ($self) = @_;
    return $self->{updated};
}

sub doned {
    my ($self) = @_;
    return $self->{doned};
}

sub subject {
    my ($self, $value) = @_;
    if (@_ == 2) {
        _validate_string($value, 'subject');
        $self->{subject} = $value;
        $self->{updated} = time();
    }

    return $self->{subject};
}

sub description {
    my ($self, $value) = @_;
    if (@_ == 2) {
        _validate_string($value, 'description');
        $self->{description} = $value;
        $self->{updated} = time();
    }

    return $self->{description};
}

sub status {
    my ($self, $value) = @_;
    if (@_ == 2) {
        _validate_status($value, 'status');
        $self->{status} = $value;
        $self->{updated} = time();
        $self->_updated_status();
    }

    return $self->{status};
}

sub status_text {
    my ($self) = @_;
    return $STATUS_TEXT{$STATUS_REVERSE{$self->{status}}};
}

sub update {
    my ($self, %params) = @_;
    my $changed = 0;
    for my $key (qw/subject description status/) {
        if (defined $params{$key}) {
            # Validate the inputs
            if (my $validate_fn = $validators->{$key}) {
                &$validate_fn($params{$key}, $key);
            }

            # Set the value
            $self->{$key} = $params{$key};

            # Update the dependencies if any
            if (my $update_fn = $update->{$key}) {
                &$update_fn($self);
            }
            $changed = 1;
        }
    }
    return $changed;
}

# Persistence
sub TO_JSON {
    my $self = shift;
    return {
        %{ $self }
    };
}

sub make_from_hash {
    my $params = shift;
    return Cpanel::Plugins::Cpanel::Todo::Item->new(%$params);
}


sub _validate_status {
    my ($value, $key) = @_;
    if (! grep { $value == $_ } values %STATUS) {
        Carp::confess "Not a valid status: $value.";
    }
}

sub _validate_integer {
    my ($value, $key) = @_;
    Carp::confess "Not a valid number in $key: $value." if ($value !~ m/^[0-9]*$/);
}

sub _validate_datetime {
    my ($value, $key) = @_;
    Carp::confess "Not a valid date in $key: $value." if ($value !~ m/^[0-9]*$/);
}

sub _validate_string {
    my ($value, $key) = @_;
    # Nothing yet
}

sub _updated_status {
    my ($self, %params) = @_;

    # Don't update the doned field if its
    # provided in the update explicitly.
    return if grep { $_ eq 'doned'} keys %params;

    # Update the doned field.
    if ($self->{status} == $STATUS{done}) {
        $self->{doned} = time();
    }
    else {
        $self->{doned} = undef;
    }
}

1;
