package Form::Functional;
# ABSTRACT: A forms system which works for you, not against you.
use strict;
use warnings;

our $VERSION = '0.001';

1;

__END__

=head1 SYNOPSIS

    FIXME

=head1 DESCRIPTION

Form::Functional is designed to produce powerful, but conceptually simple
forms. It isn't tied to any specific use-case, such as web forms, instead
preferring to stay flexible.

Form generators (herein called C<Reflectors>) are provided by the sister package
L<Data::Reflector>, which has consumers to generate forms from common sources
such as L<DBIx::Class> and for L<Moose> classes.

A simple form renderer is also provided to autogenerate HTML for your forms, although
it is easy to write a renderer to generate non-HTML forms.

=head1 ARCHITECTURE

There are two components in Form::Functional, Fields and processed forms. An
un-processed form is just a compound field (i.e. a field composed of multiple
sub-fields), in much the same way as, for example, a date selection control
with year/month/day.

Data is supplied to a form, and a new L<Form::Functional::Processed> is generated
which conatains an errors encountered during processing.

=cut

