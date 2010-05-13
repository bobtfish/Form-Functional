package Form::Functional;
# ABSTRACT: Reasonable Forms taking advantage of immutability and functional data structures

use Moose 0.90;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw(HashRef);
use namespace::autoclean;

extends 'Form::Functional::Field';
with 'Form::Functional::Field::Compound' => {
    fields => {
        required => 1,
    },
};

# convenience wrapper, i guess
method process ($values) {
    defined $_ && confess $_ for HashRef->validate($values);
    $self->validate($values)->[0];
}

__PACKAGE__->meta->make_immutable;

1;
