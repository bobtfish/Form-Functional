package Form::Functional::FieldCoercion;

use Moose;
use namespace::autoclean;

has inflator => (
    is        => 'ro',
    predicate => 'has_inflator',
);

has deflator => (
    is        => 'ro',
    predicate => 'has_deflator',
);

__PACKAGE__->meta->make_immutable;

1;
