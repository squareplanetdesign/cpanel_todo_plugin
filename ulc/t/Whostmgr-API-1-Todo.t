# Whostmgr/API/1/Todo.t

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

use_ok('Whosmgr::API::1::Todo', 'Module loads ok');

subtest "" => sub {
    ok 1;
}