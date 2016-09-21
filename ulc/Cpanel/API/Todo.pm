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
