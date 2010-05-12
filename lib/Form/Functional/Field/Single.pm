package Form::Functional::Field::Single;
# ABSTRACT: A single standalone field within a form

use Moose::Role;
use namespace::autoclean;

around validate => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig(@_) if @_ == 1;
    return [ 'single fail FIXME' ];
};

1;
