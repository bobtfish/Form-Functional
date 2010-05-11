package Form::Functional;
# ABSTRACT: Reasonable Forms taking advantage of immutability and function data structures

use Moose 0.90;
use Method::Signatures::Simple;
use MooseX::Types::LoadableClass qw(ClassName);
use namespace::autoclean;

extends 'Form::Functional::Field';
with 'Form::Functional::Field::Compound' => {
    fields => {
        required => 1,
    },
};

__PACKAGE__->meta->make_immutable;

1;
