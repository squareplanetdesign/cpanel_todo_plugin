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
use Test::More tests => 5 + 1;
use Test::NoWarnings;
use Test::Exception;
use Test::MockModule;
use Test::Deep;
use Test::MockTime qw( :all );
# For mocks
use DateTime;

use_ok('Cpanel::Plugins::Cpanel::Todo::Item', 'Module loads ok');

subtest "Test item with default data" => sub {
    set_absolute_time(100);

    my $now1 = time();
    my $item = Cpanel::Plugins::Cpanel::Todo::Item->new();
    ok $item, 'Able to create a TODO item with default data.';

    is $item->id(), 0, "Items id is initialized.";
    is $item->subject(), '', 'Items subject is initialized.';
    is $item->description(), '', 'Items description is initialized.';
    is $item->status(), $Cpanel::Plugins::Cpanel::Todo::Item::STATUS{todo}, 'Items status is initialized.';
    is $item->status_text(), "TODO", 'Items status text matches expected value.';
    is $item->created(), $now1, 'Items creation date set right';
    is $item->updated(), $now1, 'Items update date set right';
    is $item->doned(), undef, 'Items doned date is undef';

    set_relative_time(200);
    my $now2 = time();
    is $item->subject("new subject"), "new subject", "Items subject updated";
    is $item->updated(), $now2, "Updated date is advanced.";

    set_relative_time(400);
    my $now3 = time();
    is $item->description("new description"), "new description", "Items subject updated";
    is $item->updated(), $now3, "Updated date is advanced.";

    set_relative_time(600);
    my $now4 = time();
    is $item->status($Cpanel::Plugins::Cpanel::Todo::Item::STATUS{done}), $Cpanel::Plugins::Cpanel::Todo::Item::STATUS{done} , "Items status updated";
    is $item->status_text(), "Done", 'Items status text matches expected value.';
    is $item->updated(), $now4, "Updated date is advanced.";
    is $item->doned(), $now4, "Doned date is set.";

    restore_time();
};

subtest "Test item with valid initialization data" => sub {

    set_absolute_time(100);

    my $now1 = time();
    my $item = Cpanel::Plugins::Cpanel::Todo::Item->new(
        id      => 1,
        subject => 'new subject',
        description => 'new description',
        status => $Cpanel::Plugins::Cpanel::Todo::Item::STATUS{done},
    );
    ok $item, 'Able to create a TODO item with default data.';

    is $item->id(), 1, "Items id is initialized.";
    is $item->subject(), 'new subject', 'Items subject is initialized.';
    is $item->description(), 'new description', 'Items description is initialized.';
    is $item->status(), $Cpanel::Plugins::Cpanel::Todo::Item::STATUS{done}, 'Items status is initialized.';
    is $item->status_text(), "Done", 'Items status text matches expected value.';
    is $item->created(), $now1, 'Items creation date set right';
    is $item->updated(), $now1, 'Items update date set right';
    is $item->doned(), $now1, 'Items doned date is undef';

    set_relative_time(200);
    my $now2 = time();
    is $item->subject("updated subject"), "updated subject", "Items subject updated";
    is $item->updated(), $now2, "Updated date is advanced.";

    set_relative_time(400);
    my $now3 = time();
    is $item->description("updated description"), "updated description", "Items subject updated";
    is $item->updated(), $now3, "Updated date is advanced.";

    set_relative_time(600);
    my $now4 = time();
    is $item->status($Cpanel::Plugins::Cpanel::Todo::Item::STATUS{todo}), $Cpanel::Plugins::Cpanel::Todo::Item::STATUS{todo} , "Items status updated";
    is $item->status_text(), "TODO", 'Items status text matches expected value.';
    is $item->updated(), $now4, "Updated date is advanced.";
    is $item->doned(), undef, "Doned date is unset.";

    restore_time();
};

subtest "Test item with all initialization data" => sub {

    my $item = Cpanel::Plugins::Cpanel::Todo::Item->new(
        id      => 1,
        subject => 'new subject',
        description => 'new description',
        status => $Cpanel::Plugins::Cpanel::Todo::Item::STATUS{done},
        created => 101,
        updated => 202,
        doned   => 303,
    );

    ok $item, 'Able to create a TODO item with default data.';

    is $item->id(), 1, "Items id is initialized.";
    is $item->subject(), 'new subject', 'Items subject is initialized.';
    is $item->description(), 'new description', 'Items description is initialized.';
    is $item->status(), $Cpanel::Plugins::Cpanel::Todo::Item::STATUS{done}, 'Items status is initialized.';
    is $item->status_text(), "Done", 'Items status text matches expected value.';
    is $item->created(), 101, 'Items creation date set from raw data';
    is $item->updated(), 202, 'Items update date set from raw data';
    is $item->doned(), 303, 'Items doned date is set from raw data';
};

subtest "Test item with valid initialization data" => sub {

    set_absolute_time(100);

    my $now1 = time();
    my $item = Cpanel::Plugins::Cpanel::Todo::Item->new(
        subject => 'new subject',
        description => 'new description',
        status => $Cpanel::Plugins::Cpanel::Todo::Item::STATUS{done},
    );
    ok $item, 'Able to create a TODO item with default data.';
    is_deeply $item->TO_JSON(), {
            id          => 0,
            subject     => 'new subject',
            created     => $now1,
            updated     => $now1,
            doned       => $now1,
            description => 'new description',
            status      => $Cpanel::Plugins::Cpanel::Todo::Item::STATUS{done},
        }, 'Converts to JSON correctly.';
};
