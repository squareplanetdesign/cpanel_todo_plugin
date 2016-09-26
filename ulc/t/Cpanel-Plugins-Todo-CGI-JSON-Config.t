# Cpanel-Plugins-Todo-CGI-JSON-Config.t

use lib '..';

# Test modules
use Test::More tests => 7 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::MockModule;
use Test::Deep;
use Test::MockTime qw( :all );

# Other modules
use Cpanel::Plugins::Todo::Config ();

# Locally defined below
$INC{"Cpanel.pm"} = 1;
$INC{"Whostmgr/ACLS.pm"} = 1;

use_ok('Cpanel::Plugins::Todo::CGI::JSON::Config', 'Module loads ok');

subtest "When attempting to run the cgi as non-root, user should get an unauthorized error." => sub {

    Cpanel::init_cp( appname => 'whostmgr', user => 'reseller', isreseller => 1 );
    Whostmgr::ACLS::init_acls( root => 0 );

    my $cgi = Cpanel::Plugins::Todo::CGI::JSON::Config->new();
    my $got = $cgi->run();

    like $got, qr/401 Unauthorized/, "Got unauthorized as expected";

};

subtest "When loading the configuration fails, user should get a server error." => sub {

    Cpanel::init_cp( appname => 'whostmgr', user => 'root' );
    Whostmgr::ACLS::init_acls( root => 1 );

    my $mock = Test::MockModule->new('Cpanel::Plugins::Todo::Config');
    $mock->mock(new => sub { die "load failed" });

    my $cgi = Cpanel::Plugins::Todo::CGI::JSON::Config->new();
    my $got = $cgi->run();

    like $got, qr/500 Server error/, "Got server error as expected";
    like $got, qr/load failed/, "The body includes the details of the exception.";

    $mock = undef;
};

subtest "When loading the configuration fails w/o exception, user should get a server error." => sub {

    Cpanel::init_cp( appname => 'whostmgr', user => 'root' );
    Whostmgr::ACLS::init_acls( root => 1 );

    my $mock = Test::MockModule->new('Cpanel::Plugins::Todo::Config');
    $mock->mock(new => sub { return; });

    my $cgi = Cpanel::Plugins::Todo::CGI::JSON::Config->new();
    my $got = $cgi->run();

    like $got, qr/500 Server error/, "Got server error as expected";
    like $got, qr/Failed to load the configuration/, "The body includes a generic failure message.";

    $mock = undef;
};

subtest "When running the cgi with an unsupported, user should get a server error." => sub {

    Cpanel::init_cp( appname => 'whostmgr', user => 'root' );
    Whostmgr::ACLS::init_acls( root => 1 );

    foreach my $method ( qw/PUT DELETE HEAD/) {
        local $ENV{ 'REQUEST_METHOD' } = $method;

        my $cgi = Cpanel::Plugins::Todo::CGI::JSON::Config->new();
        my $got = $cgi->run();

        like $got, qr/405 Method Not Allowed/, "Got method not allowed as expected";
        like $got, qr/\Q$method\E/, "The body includes a message about the unsupported method: $method.";
    }

};

subtest "When a user requests the configuration they get the current configuration." => sub {

    Cpanel::init_cp( appname => 'whostmgr', user => 'root' );
    Whostmgr::ACLS::init_acls( root => 1 );

    my $expected_json = generate_config(1);

    my $mock = Test::MockModule->new('Cpanel::Plugins::Todo::Config');
    $mock->mock(
        _exists => sub {
            return 1;
        },
        load => sub {
            my $self = shift;
            $self->load_json($expected_json);
        }
    );

    local $ENV{ 'REQUEST_METHOD' } = "GET";

    my $cgi = Cpanel::Plugins::Todo::CGI::JSON::Config->new();
    my $got = $cgi->run();

    like $got, qr/200 OK/, "Got configuration as expected.";
    cmp_deeply count($got), { 'true' => 1, 'false' => 2 }, "The body includes the configuration.";

    $mock = undef;
};

subtest "When a user requests to change the configuration, it works." => sub {

    Cpanel::init_cp( appname => 'whostmgr', user => 'root' );
    Whostmgr::ACLS::init_acls( root => 1 );

    my $expected_json = generate_config(1);

    my $mock = Test::MockModule->new('Cpanel::Plugins::Todo::Config');
    $mock->mock(
        _exists => sub {
            return 1;
        },
        load => sub {
            my $self = shift;
            $self->load_json($expected_json);
        }
    );

    local $ENV{ 'REQUEST_METHOD' } = "GET";
    my $cgi = Cpanel::Plugins::Todo::CGI::JSON::Config->new();
    my $got = $cgi->run();

    like $got, qr/200 OK/, "Got configuration as expected.";
    cmp_deeply count($got), { 'true' => 1, 'false' => 2 }, "The body includes the configuration.";

    my $new_config = generate_config(0);
    local $ENV{ 'REQUEST_METHOD' } = "SET";
    local $ENV{ 'CONTENT_TYPE' }   = 'application/json';
    local $ENV{ 'CONTENT_LENGTH' } = length $new_config;

    use URL::Encode ();
    my $enc_config = "JSON=" . URL::Encode::url_encode($new_config);
    open( $stdin, '<', \$enc_config) || die;

    $cgi = Cpanel::Plugins::Todo::CGI::JSON::Config->new($stdin);
    $got = $cgi->run();

    like $got, qr/200 OK/, "Got configuration as expected.";
    cmp_deeply count($got), { 'false' => 3 }, "The body includes the updated configuration.";

    $mock = undef;
};

exit;

sub generate_config {
    my $enabled = shift;
    my $out = $enabled == 1 ? 'true' : 'false';
    return << "JSON";
{
    "whm": {
        "enabled": false
    },
    "cpanel": {
        "enabled": $out
    },
    "webmail": {
        "enabled": false
    }
}
JSON
}

sub count {
    my $json = shift;
    my %count;

    foreach my $str (grep { $_; } split /\s+|["{},:]/, $json) {
        $count{$str}++ if ($str eq 'true' || $str eq 'false');
    }
    return \%count;
}

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

package Whostmgr::ACLS;

use Test::More;

my $is_root = 0;

sub init_acls {
    my %hash = @_;
    $is_root = $hash{root} ? 1 : 0;
}

sub hasroot {
    return $is_root;
}

1;
