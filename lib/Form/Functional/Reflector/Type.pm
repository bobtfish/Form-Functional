package Form::Functional::Reflector::Type;
use Moose;
use Method::Signatures::Simple;
use Moose::Util::TypeConstraints;
use MooseX::Types::Structured qw/ Dict Optional /; # FIXME - remove
use aliased 'Form::Functional::Field'; # FIXME - remove
use Form::Functional::Types qw/ TypeConstraint /;
use Form::Functional::Reflector::Types qw/ NameAndConstraintPair /;
use namespace::autoclean;

use aliased 'Form::Functional::Reflector::FieldBuilder::Default' => 'DefaultFieldBuilder';

method get_fields_from_reflectee ($tc) {
    my @constraints = @{ $tc->type_constraints };
    pop @constraints if scalar(@constraints) % 2; # FIXME - Fugly! Deal with slurpy by popping it off the end
    my %constraints = @constraints;
    return map { [ $_ => $constraints{$_} ] } keys %constraints;
}

method validate_reflectee ($type_or_name){
    my $tc = blessed($type_or_name) ? $type_or_name : find_type_constraint($type_or_name);
    confess "Could not find type constraint named '$type_or_name', is is defined?"
        unless $tc;
    confess "$tc is not a Moose::Meta::TypeConstraint"
        unless $tc->isa('Moose::Meta::TypeConstraint');
    # FIXME - reflecting on something that's not a subtype of HashRef
    #         is entirely valid. the result just won't be a compound
    #         field.
    confess "$tc is not a Dict"
        unless $tc->is_a_type_of(Dict);
    return $tc;
}

with 'Form::Functional::Reflector';

has '+field_builder' => (
    default => sub { DefaultFieldBuilder->new(
        item_constraint => NameAndConstraintPair,
    ) },
);

__PACKAGE__->meta->make_immutable;
