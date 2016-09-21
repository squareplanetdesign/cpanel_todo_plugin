package Fake::Args;

sub new {
    my ($class, %opts) = @_;

    my $now =  time();
    my $self = bless {
        (%opts)
    }, $class;

    return  $self;
}

sub get {
    my ($self, $name) = @_;
    return $self->{$name};
}

sub set {
    my ($self, $name, $value) = @_;
    $self->{$name} = $value;
    return $self->{$name}
}

1;

