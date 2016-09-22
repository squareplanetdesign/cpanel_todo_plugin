package Cpanel::ThirdParty::Todo::Api;

use Cpanel                         ();
use Cpanel::ThirdParty::Todo::Item ();
use File::Slurp                    ();
use File::Path                     ();
use Try::Tiny                      ();
use JSON                           ();

our $TODO_FILENAME = 'todo.json';

sub new {
    my ($class, %opts) = @_;
    my $self = bless {
        is_loaded  => 0,
        is_changed => 0,
        max_id     => 0,
        %opts
    }, $class;

    $self->init();

    return $self;
}

sub init {
    my $self = shift;

    $self->{list} = [];

    my @user_info = _get_user();

    if (!$self->{home}) {
        $self->{home} = $user_info[7];
    }

    if (!defined $self->{autoload}) {
        $self->{autoload} = 1;
    }

    if (!defined $self->{autosave}) {
        $self->{autosave} = 0;
    }

    if (!_is_virtual() && !_is_reseller()) {
        $self->{file} = "$self->{home}/$TODO_FILENAME";
    }
    elsif (_is_virtual()) {
        my $path = $self->{home} . '/virtual/' . _virtual_user();
        File::Path::make_path($path);
        $self->{file} = "$path/$TODO_FILENAME";
    }
    elsif (_is_reseller()) {
        my $path = $self->{home} . '/resellers/' . _reseller_user();
        File::Path::make_path($path);
        $self->{file} = "$path/$TODO_FILENAME";
    }

    if ($self->{autoload}) {
        $self->load();
    }
}

sub _get_user {
    return (getpwuid $<);
}

sub _is_reseller {
    return $Cpanel::isreseller;
}

sub _is_virtual {
    return $Cpanel::authuser =~ m/[^@]*@[^@]/;
}

sub _virtual_user {
    return $Cpanel::authuser;
}

sub _reseller_user {
    return $Cpanel::authuser;
}

sub file {
    my $self = shift;
    return $self->{file} || '';
}

sub add {
    my $self = shift;
    my (%params) = @_;
    $params{id} = ++$self->{max_id};
    my $todo = Cpanel::ThirdParty::Todo::Item->new(%params);
    push @{$self->{list}}, $todo;
    $self->{is_changed} = 1;
    if ($self->{autosave}) {
        $self->save();
    }
    return $todo;
}

sub update {
    my $self = shift;
    my %params = @_;

    die "id is required" if !defined $params{id};

    my $id = delete $params{id};
    return if !%params;

    my $matches = $self->find_by(id => $id);

    if (@$matches) {
        $self->{is_changed} = $matches->[0]->update(%params);
    }

    if ($self->{is_changed} && $self->{autosave}) {
        $self->save();
    }
    return $matches->[0];
}

sub remove {
    my $self = shift;
    my %filter = @_;

    my $removes = $self->find_by(%filter);
    return if !@{$removes};

    my $len_before = @{$self->{list}};

    foreach my $remove (@{$removes}) {
        $self->{list} = [ grep {
                $_->id() != $remove->id()
            } @{$self->{list}} ];
    }

    my $len_after = @{$self->{list}};

    if ($len_before > $len_after) {
        $self->{is_changed} = 1;
    }

    if ($self->{is_changed} && $self->{autosave}) {
        $self->save();
    }

    return $removes;
}

sub list {
    my $self = shift;
    return $self->{list};
}

sub mark {
    my $self = shift;
    my ($id, $status) = @_;
    my $item = $self->find_by(id => $id);

    if ($item) {
        $item->status($status);
        $self->{is_changed} = 1;

        if ($self->{autosave}) {
            $self->save();
        }
    }
    return $item;
}

sub find_by {
    my $self = shift;
    my %filter = @_;

    if (!keys %filter) {
        return [];
    }

    my @list = ( @{$self->{list}} );
    my @keys = keys %filter;

    foreach my $key (@keys) {
        my $value = $filter{$key};

        if (ref($value) eq 'CODE') {
            @list = grep { &$value($_, $key) } @list;
        }
        elsif (!ref($value)) {
            if ($value eq $value + 0) {
                # Number
                @list = grep { $value == $_->{$key} } @list;
            }
            else {
                # String
                @list = grep { $value eq $_->{$key} } @list;
            }
        }
    }

    return \@list;
}

sub load {
    my $self = shift;

    $self->{exception} = undef;

    if (!-e $self->{file}) {
        $self->{is_loaded}  = 1;
        return;
    }

    my $list = $self->_load_list();
    for (my $i = 0, $l = @$list; $i < $l; $i++) {
        my $item = $list->[$i];

        if ($item->{id} > $self->{max_id}) {
            $self->{max_id} = $item->{id};
        }

        $list->[$i] = Cpanel::ThirdParty::Todo::Item::make_from_hash($item);
    }

    $self->{is_changed} = 0;
    $self->{is_loaded}  = 1;

    $self->{list} = $list;
}

sub _load_list {
    my $self = shift;

    my $json = eval { File::Slurp::read_file($self->{file})};
    if ($exception = $@) {
        $self->{exception} = $exception;
        return 0;
    }

    my $list = [];
    if ($json) {
        my $list = eval { JSON::decode_json($json) };
        if( my $exception = $@) {
            $self->{exception} = $exception;
            return 0;
        };
    }

    return $list;
}

sub save {
    my $self = shift;
    $self->{exception} = undef;

    my $json = eval {
        JSON->new->pretty->allow_blessed->convert_blessed->encode($self->{list});
    };
    if( my $exception = $@ ) {
        $self->{exception} = $exception;
        return 0;
    };

    eval { File::Slurp::write_file($self->{file}, $json)};
    if ( my $exception = $@ ) {
        $self->{exception} = $exception;
        return 0;
    }

    $self->{is_changed} = 0;

    return 1;
}

1;
