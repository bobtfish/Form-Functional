package Form::Functional::Field::WithInitValue;
# ABSTRACT: Encapsulates the behaviour of a field with an initial value.
use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw(HashRef ArrayRef Value Undef);
use namespace::autoclean;

# FIXME - Should we not call this type_constraint to fit in with everything else?
parameter tc => (
    is       => 'ro',
    isa      => 'Moose::Meta::TypeConstraint',
    required => 1,
);

role {
    my ($p) = @_;
    my $tc = $p->tc;

    my ($trait) = $tc->is_a_type_of(ArrayRef) ? ('Array')
                : $tc->is_a_type_of(HashRef)  ? ('Hash') : ();

    has init_value => (
        isa      => $tc,
        required => 1,
        ($trait ? (traits  => [$trait],
                   handles => {
                       init_value => 'elements',
                   })
                : (is => 'ro')),
    );
};

1;

=head1 DESCRIPTION

Some fields (e.g. select lists) can be forced to have an initial value.

This trait enforces that this initial value is passed in during construction of the field
and provides an init_value accessor for the field.

FIXME

=cut
