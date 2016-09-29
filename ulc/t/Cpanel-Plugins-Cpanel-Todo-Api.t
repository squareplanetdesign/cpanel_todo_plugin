# Copyright 2016 cPanel, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use lib '.';

# Test modules
use Test::More tests => 9 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::MockModule;
use Test::Deep;
use Test::MockTime qw( :all );

# Other modules
use File::Temp  ();
use File::Slurp ();
use JSON        ();

# Locally defined below
$INC{"Cpanel.pm"} = 1;

use_ok('Cpanel::Plugins::Cpanel::Todo::Api', 'Module loads ok');

my $dir = File::Temp->newdir();
mkdir "$dir/root";
mkdir "$dir/root/resellers";
mkdir "$dir/root/resellers/reseller";
mkdir "$dir/home";
mkdir "$dir/home/user";

my @tests = (
    {
        app        => 'whm',
        real_user  => 'root',
        auth_user  => 'root',
        isreseller => 0,
        dir        => "$dir/root",
        comment    => 'todo in WHM as root.',
        expected_file => "$dir/root/todo.json",
    },
    {
        app        => 'whm',
        real_user  => 'root',
        auth_user  => 'reseller',
        isreseller => 1,
        dir        => "$dir/root",
        comment    => 'todo in WHM as reseller.',
        expected_file => "$dir/root/resellers/reseller/todo.json",
    },
    {
        app        => 'cpanel',
        real_user  => 'root',
        auth_user  => 'root',
        isreseller => 0,
        dir        => "$dir/root",
        comment    => 'todo in cPanel as root.',
        expected_file => "$dir/root/todo.json",
    },
    {
        app        => 'cpanel',
        real_user  => 'reseller',
        auth_user  => 'reseller',
        isreseller => 1,
        dir        => "$dir/root",
        comment    => 'todo in cPanel as user.',
        expected_file => "$dir/root/resellers/reseller/todo.json",
    },
    {
        app        => 'cpanel',
        real_user  => 'user',
        auth_user  => 'user',
        isreseller => 0,
        dir        => "$dir/home/user",
        comment    => 'todo in cPanel as user.',
        expected_file => "$dir/home/user/todo.json",
    },
    {
        app        => 'cpanel',
        real_user  => 'user',
        auth_user  => 'sub@user.tld',
        isreseller => 0,
        dir        => "$dir/home/user",
        comment    => 'todo in cPanel as virtual user.',
        expected_file => "$dir/home/user/virtual/sub\@user.tld/todo.json",
    },
    {
        app        => 'webmail',
        real_user  => 'user',
        auth_user  => 'user',
        isreseller => 0,
        dir        => "$dir/home/user",
        comment    => 'todo in Webmail as user',
        expected_file => "$dir/home/user/todo.json",
    },
    {
        app        => 'webmail',
        real_user  => 'user',
        auth_user  => 'sub@user.tld',
        isreseller => 0,
        dir        => "$dir/home/user",
        comment    => 'todo in Webmail as virtual user.',
        expected_file => "$dir/home/user/virtual/sub\@user.tld/todo.json",
    },
);

for my $test (@tests) {

    subtest "Test api methods for $test->{comment}." => sub {
        my ($args) = @_;

        my $mock = Test::MockModule->new('Cpanel::Plugins::Cpanel::Todo::Api');
        $mock->mock('_get_user', sub {
            return ( $args->{real_user}, undef, undef, undef, undef, undef, undef, $args->{dir} ) });
        Cpanel::init_cp(
            appname    => $args->{app},
            user       => $args->{real_user},
            authuser   => $args->{auth_user},
            isreseller => $args->{isreseller},
        );

        my $api = Cpanel::Plugins::Cpanel::Todo::Api->new();

        cmp_deeply {%{ $api }}, superhashof({
                'is_changed' => 0,
                'is_loaded' => 1,
                'list'      => [],
                'max_id'    => 0,
            }), "Loaded empty list when no file exists.";

        $api->add(subject => "something new 1");

        cmp_deeply {%{ $api }}, superhashof({
                'is_changed' => 1,
                'is_loaded'  => 1,
                'max_id'     => 1,
                'list'       => array_each(isa('Cpanel::Plugins::Cpanel::Todo::Item')),
            }), "Loaded empty list when no file exists.";

        cmp_deeply $api->list(), array_each(isa('Cpanel::Plugins::Cpanel::Todo::Item')), "list() api returns list";
        cmp_deeply scalar @{$api->list()}, 1, "list() api returns list";

        $api->add(
            subject => "something new 2",
            description => "blarg blah blu"
        );

        cmp_deeply {%{ $api }}, superhashof({
                'is_changed' => 1,
                'is_loaded'  => 1,
                'max_id'     => 2,
                'list'       => array_each(isa('Cpanel::Plugins::Cpanel::Todo::Item')),
            }), "Loaded empty list when no file exists.";

        cmp_deeply $api->list(), array_each(isa('Cpanel::Plugins::Cpanel::Todo::Item')), "list() api returns list";
        cmp_deeply scalar @{$api->list()}, 2, "list() api returns list";
        cmp_deeply {%{$api->list()->[0]}}, superhashof({
                subject => 'something new 1'
            }), "First items subject is set correctly";
        cmp_deeply {%{$api->list()->[1]}}, superhashof({
                subject => 'something new 2',
                description => 'blarg blah blu',
            }), "First items subject is set correctly";

        dies_ok { $api->update()} 'update() dies if no id is passed.';

        $api->update(id => 1, subject => "something new!!!");

        cmp_deeply $api->list(), array_each(isa('Cpanel::Plugins::Cpanel::Todo::Item')), "list() api returns list";
        cmp_deeply scalar @{$api->list()}, 2, "list() api returns list";
        cmp_deeply {%{$api->list()->[0]}}, superhashof({
                subject => 'something new!!!'
            }), "First items subject is updated correctly";

        $api->remove( id => 1);
        cmp_deeply $api->list(), array_each(isa('Cpanel::Plugins::Cpanel::Todo::Item')), "list() api returns list";
        cmp_deeply scalar @{$api->list()}, 1, "list() api returns list with item successfully removed.";
        cmp_deeply {%{$api->list()->[0]}}, superhashof({
                subject => 'something new 2',
                description => 'blarg blah blu',
            }), "First item is now the one with id 2.";
        is $api->file(), $test->{expected_file}, "Persistent file path looks right for the user.";

        $api->save();
        ok -e $api->file(), "Persistent file exists after a save.";

        $api = undef;

        $api = Cpanel::Plugins::Cpanel::Todo::Api->new();

        my $expect = noclass(superhashof({
            'is_changed' => 0,
            'is_loaded' => 1,
            'list'      => [
                noclass(
                    superhashof({
                        id          => re(qr{\d+}),
                        subject     => ignore(),
                        description => ignore(),
                        created     => re(qr{\d+}),
                        updated     => re(qr{\d+}),
                        doned       => ignore(),
                        status      => re(qr{[12]}),
                    })
                )
            ],
            'max_id'    => 2,
        }));

        cmp_deeply($api, $expect, "Loaded existing list.")
            or diag explain $api, $expect;

        # Clean up
        unlink $test->{expected_file};
    }, $test;
}

exit;

package Cpanel;

use Test::More;

our $appname    = '';
our $user       = '';
our $authuser   = '';
our $isreseller = 0;

sub init_cp {
    my %args = @_;

    $Cpanel::appname = $args{appname} || 'cpanel';
    $Cpanel::isreseller = $args{isreseller} || 0;
    $Cpanel::user    = $args{user};
    $Cpanel::authuser = $args{authuser} || $args{user};
}

sub dump {
    diag "dump: ", explain {
        appname => $Cpanel::appname,
        user    => $Cpanel::user,
        authuser => $Cpanel::authuser,
        isreseller => $Cpanel::isreseller,
    };
}

1;
