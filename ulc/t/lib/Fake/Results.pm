package Fake::Results;

sub new {
    my ($class, %opts) = @_;

    my $now =  time();
    my $self = bless {
        (%opts)
    }, $class;

    return  $self;
}
