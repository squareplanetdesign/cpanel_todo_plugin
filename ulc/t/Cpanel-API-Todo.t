# t/Cpanel-API-Todo.t

use lib '..';
use lib 't/lib';

# Test modules
use Test::More tests => 10 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::MockModule;
use Test::Deep;
use Test::MockTime qw( :all );

# Locally defined below
BEGIN {
    $INC{"Cpanel.pm"} = 1;
}

# Other modules
use Cpanel      ();
use DateTime    ();
use File::Temp  ();
use File::Slurp ();
use JSON        ();

# Fake modules
use Fake::Args    ();
use Fake::Results ();

# Application modules
use Cpanel::ThirdParty::Todo::Api    ();
use Cpanel::ThirdParty::Todo::Config ();
use Cpanel::ThirdParty::Todo::Item   ();


use_ok('Cpanel::API::Todo', 'Module loads ok');

my $_hasfeature = 1;
sub hasfeature {
    return $_hasfeature;
}

my $_enabled = 1;
my $mock_config = Test::MockModule->new('Cpanel::ThirdParty::Todo::Config');
$mock_config->mock('load' => sub {
    return {
        cpanel => {
            enabled => $_enabled,
        }
    };
});

my $_list = [];
my $mock_api = Test::MockModule->new('Cpanel::ThirdParty::Todo::Api');
$mock_api->mock(
    '_list_exists' => sub {
        return 1;
    },
    '_load_list' => sub {
        return $_list;
    },
    'save' => sub {
        return;
    },
);

my $now = time();
my $updated = $now + 20;
my $doned   = $now + 20;

subtest "list todos from an empty list" => sub {
    init_user();
    init_empty_list();
    my ($args, $results) = setup_api_call();
    my $got = Cpanel::API::Todo::list_todos($args, $results);
    my $expected = [];

    ok $got, "list_todo() correctly returned true for the operation";
    cmp_deeply($results->data(), $expected, "list_todos() correctly returned an empty list.")
        or diag "GOT:\n", explain $results, "EXPECTED:\n", explain $expected;
};

subtest "list todos from an list with several items" => sub {
    init_user();
    init_item_list(3);
    my ($args, $results) = setup_api_call();
    my $got = Cpanel::API::Todo::list_todos($args, $results);
    my $expected = expect(3);

    ok $got, "list_todo() correctly returned true for the operation";
    cmp_deeply($results->data(), $expected, "list_todos() correctly returned a list of 3 items.")
        or diag "GOT:\n", explain $results, "EXPECTED:\n", explain $expected;
};

subtest "add a new todo to an empty list" => sub {
    init_user();
    init_empty_list();
    my ($args, $results) = setup_api_call({
        subject => "subject new",
        description => "description new",
    });

    my $got = Cpanel::API::Todo::add_todo($args, $results);
    my $expected = noclass(
        superhashof({
            id          => 1,
            subject     => "subject new",
            description => "description new",
            created     => re(qr{\d+}),
            updated     => re(qr{\d+}),
            doned       => ignore(),
            status      => re(qr{[12]}),
        })
    );

    ok $got, "add_todo() correctly returned true for the operation";
    cmp_deeply($results->data(), $expected, "add_todos() correctly returned the new item.")
        or diag "GOT:\n", explain $results, "EXPECTED:\n", explain $expected;
    is @{$_list}, 1, "list was extended";
};

subtest "add a new todo to a list with data already in it." => sub {
    init_user();
    init_item_list(3);
    my ($args, $results) = setup_api_call({
        subject => "subject new",
        description => "description new",
    });

    my $got = Cpanel::API::Todo::add_todo($args, $results);
    my $expected = noclass(
        superhashof({
            id          => 4,
            subject     => "subject new",
            description => "description new",
            created     => re(qr{\d+}),
            updated     => re(qr{\d+}),
            doned       => ignore(),
            status      => re(qr{[12]}),
        })
    );

    ok $got, "add_todo() correctly returned true for the operation";
    cmp_deeply($results->data(), $expected, "add_todos() correctly returned the new item.")
        or diag "GOT:\n", explain $results, "EXPECTED:\n", explain $expected;

    is @{$_list}, 4, "list was extended";
};

subtest "attempt to remove a non-existent todo from an empty list" => sub {
    init_user();
    init_empty_list();
    my ($args, $results) = setup_api_call({
        id => 100,
    });

    my $got = Cpanel::API::Todo::remove_todo($args, $results);
    my $expected = undef;

    ok $got, "remove_todo() correctly returned true for the operation";
    cmp_deeply($results->data(), $expected, "remove_todo() correctly returned a list with 1 item.")
        or diag "GOT:\n", explain $results, "EXPECTED:\n", explain $expected;

    is @{$_list}, 0, "list was not changed";
};

subtest "attempt to remove a non-existent todo from a list with items" => sub {
    init_user();
    init_item_list(3);
    my ($args, $results) = setup_api_call({
        id => 100,
    });

    my $got = Cpanel::API::Todo::remove_todo($args, $results);
    my $expected = undef;

    ok $got, "remove_todo() correctly returned true for the operation";
    cmp_deeply($results->data(), $expected, "remove_todo() correctly returned a list with 1 item.")
        or diag "GOT:\n", explain $results, "EXPECTED:\n", explain $expected;

    is @{$_list}, 3, "list was not changed";
};

subtest "remove an existing todo from the start of the list" => sub {
    init_user();
    init_item_list(3);
    my ($args, $results) = setup_api_call({
        id => 1,
    });

    my $got = Cpanel::API::Todo::remove_todo($args, $results);
    my $expected = [
        noclass(
            superhashof({
                id          => 1,
                subject     => "subject 1",
                description => "description 1",
                created     => re(qr{\d+}),
                updated     => re(qr{\d+}),
                doned       => ignore(),
                status      => re(qr{[12]}),
            })
        )
    ];

    ok $got, "remove_todo() correctly returned true for the operation";
    cmp_deeply($results->data(), $expected, "remove_todo() correctly returned a list with 1 item.")
        or diag "GOT:\n", explain $results, "EXPECTED:\n", explain $expected;

    is @{$_list}, 2, "list was pruned";
};

subtest "remove an existing todo from the middle of the list" => sub {
    init_user();
    init_item_list(3);
    my ($args, $results) = setup_api_call({
        id => 2,
    });

    my $got = Cpanel::API::Todo::remove_todo($args, $results);
    my $expected = [
        noclass(
            superhashof({
                id          => 2,
                subject     => "subject 2",
                description => "description 2",
                created     => re(qr{\d+}),
                updated     => re(qr{\d+}),
                doned       => ignore(),
                status      => re(qr{[12]}),
            })
        )
    ];

    ok $got, "remove_todo() correctly returned true for the operation";
    cmp_deeply($results->data(), $expected, "remove_todo() correctly returned a list with 1 item.")
        or diag "GOT:\n", explain $results, "EXPECTED:\n", explain $expected;

    is @{$_list}, 2, "list was pruned";
};

subtest "remove an existing todo from the end of the list" => sub {
    init_user();
    init_item_list(3);
    my ($args, $results) = setup_api_call({
        id => 3,
    });

    my $got = Cpanel::API::Todo::remove_todo($args, $results);
    my $expected = [
        noclass(
            superhashof({
                id          => 3,
                subject     => "subject 3",
                description => "description 3",
                created     => re(qr{\d+}),
                updated     => re(qr{\d+}),
                doned       => ignore(),
                status      => re(qr{[12]}),
            })
        )
    ];

    ok $got, "remove_todo() correctly returned true for the operation";
    cmp_deeply($results->data(), $expected, "remove_todo() correctly returned a list with 1 item.")
        or diag "GOT:\n", explain $results, "EXPECTED:\n", explain $expected;

    is @{$_list}, 2, "list was pruned";
};

# subtest "attempt to update a todo that does not exist" => sub {
#     ok 1;
# };

# subtest "update a todo that exists in the list" => sub {
#     ok 1;
# };

# subtest "attempt to mark a todo that does not exist in the list as done" => sub {
#     ok 1;
# };

# subtest "mark a todo that does exists in the list as done" => sub {
#     ok 1;
# };

sub init_user {
    Cpanel::init_cp(
        appname    => 'cpanel',
        user       => 'user',
        authuser   => 'user',
        isreseller => 0,
        demo       => 0,
    );
}

sub init_demo_user {
    Cpanel::init_cp(
        appname    => 'cpanel',
        user       => 'user',
        authuser   => 'user',
        isreseller => 0,
        demo       => 1,
    );
}


sub expect {
    my ($len) = @_;
    my @list;
    foreach my $id (1..$len) {
        my $done = $id % 2 ? 2 : 1;
        push( @list, make_item($id, $now, $updated, $doned, $done) );
    }
    return \@list;
}

sub init_empty_list {
    pop @{$_list} until !@{$_list};
}

sub init_item_list {
    my ($len) = @_;
    init_empty_list();
    foreach my $id (1..$len) {
        my $done = $id % 2 ? 2 : 1;
        push( @{$_list}, make_item($id, $now, $updated, $doned, $done) );
    }
}

sub make_item {
    my ($id, $now, $updated, $doned, $done) = @_;
    return Cpanel::ThirdParty::Todo::Item->new(
        id => $id,
        subject => "subject $id",
        description => "description $id",
        created => $now,
        updated => $updated,
        doned   => ($done ? $doned : undef),
        status  => $done || 1,
    );
}

sub setup_api_call {
    my ($args_init, $results_init) = @_;
    return (
        Fake::Args->new(%$args_init),
        Fake::Results->new(%$results_init)
    );
}

{
    package Cpanel;

    use Test::More;

    our $appname    = '';
    our $user       = '';
    our $authuser   = '';
    our $isreseller = 0;
    our %CPDATA;

    sub init_cp {
        my %args = @_;

        $Cpanel::appname = $args{appname} || 'cpanel';
        $Cpanel::isreseller = $args{isreseller} || 0;
        $Cpanel::user    = $args{user};
        $Cpanel::authuser = $args{authuser} || $args{user};
        $Cpanel::CPDATA{'DEMO'} = $args{demo} || 0;
    }

    sub dump {
        diag "dump: ", explain {
            appname => $Cpanel::appname,
            user    => $Cpanel::user,
            authuser => $Cpanel::authuser,
            isreseller => $Cpanel::isreseller,
            CPDATA     => \%Cpanel::CPDATA,
        };
    }

    1;
}
