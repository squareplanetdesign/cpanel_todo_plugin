package Fake::Results;

sub new {
    my ($class, %opts) = @_;

    my $now =  time();
    my $self = bless {
        (%opts)
    }, $class;

    return  $self;
}

sub error {
    my $self = shift;
    $self->{error} = \@_ if @_;
    return $self->{error};
}

sub data {
    my $self = shift;
    $self->{data} = $_[0] if $_[0];
    return $self->{data};
}

1;


