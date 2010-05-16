package Form::Functional::Field;
# ABSTRACT: The base class for form fields
use Moose;
use namespace::autoclean;

__PACKAGE__->meta->make_immutable;

1;

=head1 DESCRIPTION

This class is actually an empty class, as all the functionality is composed from
one or more roles.

=cut
