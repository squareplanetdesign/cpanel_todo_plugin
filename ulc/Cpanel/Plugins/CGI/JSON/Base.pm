package Cpanel::Plugins::Todo::CGI::JSON::Base;

use strict;
use warnings;

use CGI                              ();

$CGI::USE_PARAM_SEMICOLONS = 0;
$CGI::DISABLE_UPLOADS      = 1;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->init(@_);
    return $self;
}

sub init {
    my $self = shift;
    $self->{page} = CGI->new(@_);
}

sub page {
    my $self = shift;
    return $self->{page};
}


sub method {
    return $ENV{ 'REQUEST_METHOD' } || '';
}

sub content_type {
    return $ENV{'CONTENT_TYPE'} || '';
}

sub server_error {
    my ($self, $message) = @_;

    $message = "Server error" . ($message ? ": $message" : "");

    my $out = $self->{page}->header(
        -content_type => 'application/json',
        -status       => '500 Server error',
    );
    $out .= << "JSON";
{
    "error": "$message",
    "status": 500
}
JSON
    return $out;
}

sub bad_request {
    my ($self, $message) = @_;

    $message = "Bad request" . ($message ? ": $message" : "");

    my $out = $self->{page}->header(
        -content_type => 'application/json',
        -status       => '400 Bad request',
    );
    $out .= << "JSON";
{
    "error": "$message",
    "status": 400
}
JSON
    return $out;
}

sub unauthorized {
    my ($self, $message) = @_;

    $message = "Unauthorized" . ($message ? ": $message" : "");

    my $out = $self->{page}->header(
        -content_type => 'application/json',
        -status       => '401 Unauthorized',
    );
    $out .= << "JSON";
{
    "error": "$message",
    "status": 401
}
JSON
    return $out;
}

sub method_not_allowed {
    my ($self) = @_;

    my $method = $self->method();
    my $message = "Method Not Allowed: $method.";

    my $out = $self->{page}->header(
        -content_type => 'application/json',
        -status       => '405 Method Not Allowed',
    );
    $out .= << "JSON";
{
    "error": "$message",
    "status": 405
}
JSON
    return $out;
}

sub success {
    my ($self, $data_json, $message, $status) = @_;

    $message = "OK" if !defined $message;
    $status  = 200 if !defined $status;

    my $out = $self->{page}->header(
        -content_type => 'application/json',
        -status       => "$status $message",
    );
    $out .= << "JSON";
{
  "data": $data_json,
  "message": "$message",
  "status": $status
}
JSON
    return $out;
}

1;
