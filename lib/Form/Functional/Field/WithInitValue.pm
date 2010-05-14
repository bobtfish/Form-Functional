package Form::Functional::Field::WithInitValue;

use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw(HashRef ArrayRef Value Undef);
use namespace::autoclean;

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
