package Cpanel::ThirdParty::CGI::JSON::Base.pm;

use CGI                              ();

my $page  = CGI->new();

sub new {
    my ($class, %opts) = @_;
    my $self = bless {
        page => CGI->new(%opts);
    };
    return  $self;
}

sub page {
    my $self = shift;
    return $self->{page};
}

sub server_error {
    my ($self, $message) = @_;

    $message = "Server error" . ($message ? ": $message" : "");

    _print $self->{page}->header(
        -content_type => 'application/json',
        -status       => '500 Server error',
    );
    _print << "JSON";
{
    "error": "$message",
    "status": 500
}
JSON

}

sub bad_request {
    my ($self, $message) = @_;

    $message = "Bad request" . ($message ? ": $message" : "");

    _print $self->{page}->header(
        -content_type => 'application/json',
        -status       => '400 Bad request',
    );
    _print << "JSON";
{
    "error": "$message",
    "status": 400
}
JSON
}

sub unauthorized {
    my ($self, $message) = @_;

    $message = "Unauthorized" . ($message ? ": $message" : "");

    _print $self->{page}->header(
        -content_type => 'application/json',
        -status       => '401 Unauthorized',
    );
    _print << "JSON";
{
    "error": "$message",
    "status": 401
}
JSON
}

sub _print {
    print @_;
}
