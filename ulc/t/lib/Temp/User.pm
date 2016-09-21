package Temp::User;

sub new {
    my ($class, %opts) = @_;

    my $self = bless {}, $class;
    $self->init(%opts);
    return  $self;
}

sub init {
    my ($self, %opts) = @_;
}

sub create_user {

}
