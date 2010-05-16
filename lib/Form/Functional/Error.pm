package Form::Functional::Error;

use Moose;
use MooseX::Types::Moose qw(Str ArrayRef);
use namespace::autoclean;

has message => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has arguments => (
    traits    => [qw(Array)],
    isa       => ArrayRef,
    predicate => 'has_arguments',
    handles   => {
        arguments => 'elements',
    },
);

has failed_type_constraint => (
    is        => 'ro',
    isa       => 'Moose::Meta::TypeConstraint',
    predicate => 'has_failed_type_constraint',
);

__PACKAGE__->meta->make_immutable;
1;
