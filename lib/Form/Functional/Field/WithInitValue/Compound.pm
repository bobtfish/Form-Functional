package Form::Functional::Field::WithInitValue::Compound;
# ABSTRACT: A role for compound fields with initial values.

use Moose::Role;
use MooseX::Types::Moose qw(HashRef);
use namespace::autoclean;

with 'Form::Functional::Field::WithInitValue' => { tc => HashRef };

1;

=head1 DESCRIPTION

Forces a C<HashRef> of initial values to be passed.

=cut
