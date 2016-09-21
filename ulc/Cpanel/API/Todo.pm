package Cpanel::API::Todo;

use Cpanel::ThirdParty::Todo::Api    ();
use Cpanel::ThirdParty::Todo::Config ();

sub add_todo {
    my ( $args, $result ) = @_;
    my ( $subject, $description, $status ) = $args->get( qw(subject description status) );
}

sub update_todo {
    my ( $args, $result ) = @_;
    my ( $id, $subject, $description, $status ) = $args->get( qw(id subject description status) );

}

sub remove_todo {
    my ( $args, $result ) = @_;
    my ( $id ) = $args->get( qw(id) );
}

sub list_todos {

}

sub mark_todo {

}

1;
