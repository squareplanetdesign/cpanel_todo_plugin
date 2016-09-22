# t/Cpanel-API-Todo.t

use lib '..';

# Test modules
use Test::More tests => 2 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::MockModule;
use Test::Deep;
use Test::MockTime qw( :all );

# Other modules
use File::Temp  ();
use File::Slurp ();
use JSON        ();

use_ok('Cpanel::API::Todo', 'Module loads ok');

my $_has_feature = 1;
sub has_feature {
    return $_has_feature;
}

my $_enabled = 1;
my $mock_config = Test::MockModule('Cpanel::ThirdParty::Todo::Config');
$mock_config->mock('load', sub {
    return {
        cpanel => {
            enabled => $_enabled;
        }
    };
});

my $_list = [];
my $mock_api = Test::MockModule('Cpanel::ThirdParty::Todo::Api');
$mock_api->mock('_load_list', sub {
    return $_list;
});
$mock_api->mock('save', sub {
    return;
});

subtest "" => sub {
    ok 1;
};

subtest "" => sub {
    ok 1;
};

subtest "" => sub {
    ok 1;
};

subtest "" => sub {
    ok 1;
};

subtest "" => sub {
    ok 1;
};

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
