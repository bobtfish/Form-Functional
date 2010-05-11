package Form::Functional::Field::Single;

use Moose::Role;
use namespace::autoclean;

around validate => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig(@_) if @_ == 1;
    return [ 'single fail FIXME' ];
};

1;
