package Form::Functional::Error;
# ABSTRACT: A validation error for a Field
use Moose;
use MooseX::Types::Moose qw(Str ArrayRef);
use namespace::autoclean;

=attr message

The validation error message, including placeholders for values.

=cut

has message => (
    is => 'ro',
    isa => Str,
    required => 1,
);

=attr arguments

The argument (i.e. values) that the field recieved.

Note that the arguments accessor returns a list rather than a reference.

=cut

has arguments => (
    traits    => [qw(Array)],
    isa       => ArrayRef,
    predicate => 'has_arguments',
    handles   => {
        arguments => 'elements',
    },
);

=attr failed_type_constraint

A reference to the type constraint which caused the failure.

Not usually useful, but present for advanced introspection.

=cut

has failed_type_constraint => (
    is        => 'ro',
    isa       => 'Moose::Meta::TypeConstraint',
    predicate => 'has_failed_type_constraint',
);

__PACKAGE__->meta->make_immutable;
1;

=head1 SYNOPSIS

=head1 DESCRIPTION

This class holds an error collected when validating a form field.

It should be noted that

=cut

