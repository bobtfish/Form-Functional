package Form::Functional::Field::Single;
# ABSTRACT: A single standalone field within a form

use Moose::Role;
use namespace::autoclean;

around validate => sub {
    my $orig = shift;
    my $self = shift;
    my ($args) = @_;

    return $self->$orig(@_) if @{ $args->{values} } == 1;
    return [$self->_new_error({ message => 'single fail FIXME' })];
};

1;
