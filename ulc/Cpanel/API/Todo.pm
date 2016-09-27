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
use strict;
use warnings;

1;

package Cpanel::API::Todo;

use Cpanel                           ();
use Cpanel::Plugins::Cpanel::Todo::Api    ();
use Cpanel::Plugins::Cpanel::Todo::Config ();

sub add_todo {
    my ( $args, $result ) = @_;
    my ( $subject, $description ) = $args->get( qw(subject description) );

    my $config = Cpanel::Plugins::Cpanel::Todo::Config->new();
    if ( !$config->param("$Cpanel::appname.enabled") ) {
        $result->error( 'Todo application is not enabled for [_1].', $Cpanel::appname );
        return;
    }

    my $feature = 'todo';
    if ( !main::hasfeature($feature) ) {
        $result->error( '_ERROR_FEATURE', $feature );
        return;
    }

    if ( $Cpanel::CPDATA{'DEMO'} ) {
        $result->error( '_ERROR_DEMO_MODE', $feature );
        return;
    }

    my $todo = Cpanel::Plugins::Cpanel::Todo::Api->new();
    my $item = $todo->add(
        subject     => $subject,
        description => $description,
    );
    $todo->save();

    if ($todo->{exception}) {
        $result->error('Failed to add todo with the following error: [_1].', $todo->{exception});
        return 0;
    }
    elsif (!$todo) {
        $result->error('Unknown error while adding todo.');
        return 0;
    }
    else {
        $result->data($item);
        return 1;
    }
}

sub update_todo {
    my ( $args, $result ) = @_;
    my ( $id, $subject, $description, $status ) = $args->get( qw(id subject description status) );

    my $config = Cpanel::Plugins::Cpanel::Todo::Config->new();
    if ( !$config->param("$Cpanel::appname.enabled") ) {
        $result->error( 'Todo application is not enabled for [_1].', $Cpanel::appname );
        return;
    }

    my $feature = 'todo';
    if ( !main::hasfeature($feature) ) {
        $result->error( '_ERROR_FEATURE', $feature );
        return;
    }

    # Make the function unusable if the cPanel account is in demo mode.
    if ( $Cpanel::CPDATA{'DEMO'} ) {
        $result->error( '_ERROR_DEMO_MODE', $feature );
        return;
    }

    my $todo = Cpanel::Plugins::Cpanel::Todo::Api->new();
    my $item = $todo->update(
        id => $id,
        (defined $subject ?     ( subject => $subject)         : ()),
        (defined $description ? ( description => $description) : ()),
        (defined $status ?      ( status => $status)           : ()),
    );
    if ($todo && $item) {
        $todo->save();
    }
    else {
        $result->error('Item not found.');
        return 0;
    }

    if ($todo->{exception}) {
        $result->error('Failed to update todo with the following error: [_1].', $todo->{exception});
        return 0;
    }
    elsif (!$todo) {
        $result->error('Unknown error while updating a todo.');
        return 0;
    }
    else {
        $result->data($item);
        return 1;
    }
}

sub remove_todo {
    my ( $args, $result ) = @_;
    my ( $id ) = $args->get( qw(id) );

    my $config = Cpanel::Plugins::Cpanel::Todo::Config->new();
    if ( !$config->param("$Cpanel::appname.enabled") ) {
        $result->error( 'Todo application is not enabled for [_1].', $Cpanel::appname );
        return;
    }

    my $feature = 'todo';
    if ( !main::hasfeature($feature) ) {
        $result->error( '_ERROR_FEATURE', $feature );
        return;
    }

    # Make the function unusable if the cPanel account is in demo mode.
    if ( $Cpanel::CPDATA{'DEMO'} ) {
        $result->error( '_ERROR_DEMO_MODE', $feature );
        return;
    }

    my $todo = Cpanel::Plugins::Cpanel::Todo::Api->new();
    my $item = $todo->remove(
        id => $id,
    );
    if ($todo && $item) {
        $todo->save();
    }
    else {
        $result->error('Item not found.');
        return 0;
    }

    if ($todo->{exception}) {
        $result->error('Failed to remove todo with the following error: [_1].', $todo->{exception});
        return 0;
    }
    elsif (!$todo) {
        $result->error('Unknown error while removing todo.');
        return 0;
    }
    else {
        $result->data($item);
        return 1;
    }
}

sub list_todos {
    my ( $args, $result ) = @_;

    my $config = Cpanel::Plugins::Cpanel::Todo::Config->new();
    if ( !$config->param("$Cpanel::appname.enabled") ) {
        $result->error( 'Todo application is not enabled for [_1].', $Cpanel::appname );
        return;
    }

    my $todo = Cpanel::Plugins::Cpanel::Todo::Api->new();
    my $items = $todo->list();

    if ($todo->{exception}) {
        $result->error('Failed to list the todos with the following error: [_1].', $todo->{exception});
        return 0;
    }
    elsif (!$todo) {
        $result->error('Unknown error while listing todos.');
        return 0;
    }
    else {
        $result->data($items);
        return 1;
    }
}

sub mark_todo {
    my ( $args, $result ) = @_;
    my ( $id, $status ) = $args->get( qw(id status) );

    my $config = Cpanel::Plugins::Cpanel::Todo::Config->new();
    if ( !$config->param("$Cpanel::appname.enabled") ) {
        $result->error( 'Todo application is not enabled for [_1].', $Cpanel::appname );
        return;
    }

    my $feature = 'todo';
    if ( !main::hasfeature($feature) ) {
        $result->error( '_ERROR_FEATURE', $feature );
        return;
    }

    # Make the function unusable if the cPanel account is in demo mode.
    if ( $Cpanel::CPDATA{'DEMO'} ) {
        $result->error( '_ERROR_DEMO_MODE', $feature );
        return;
    }

    my $todo = Cpanel::Plugins::Cpanel::Todo::Api->new();
    my $item = $todo->mark( $id, $status );
    if ($todo && $item) {
        $todo->save();
    }
    else {
        $result->error('Item not found.');
        return 0;
    }

    if ($todo->{exception}) {
        $result->error('Failed to modify the todo status with the following error: [_1].', $todo->{exception});
        return 0;
    }
    elsif (!$todo) {
        $result->error('Unknown error while changing the status of a todo.');
        return 0;
    }
    else {
        $result->data($item);
        return 1;
    }
}

1;
