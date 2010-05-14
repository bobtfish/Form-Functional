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

method old_generate_form_from ($type_or_name) {
    my $tc = blessed($type_or_name) ? $type_or_name : find_type_constraint($type_or_name);
    confess "Could not find type constraint named '$type_or_name', is is defined?"
        unless $tc;
    confess "$tc is not a Moose::Meta::TypeConstraint"
        unless $tc->isa('Moose::Meta::TypeConstraint');
    confess "$tc is not a Dict"
        unless $tc->is_a_type_of(Dict);



    my @fields;
    my %constraints;
    foreach my $name (keys %constraints) {
        my $sub_tc = $constraints{$name};
        next unless $sub_tc; # Actually skips slurpy..

        my $optional = 0;
        if ($sub_tc->is_a_type_of(Optional)) {
            $optional = 1;
            $sub_tc = $sub_tc->type_parameter;
        }

        push(@fields,
            $name => Field->new(
                coerce => 0,
                required => !$optional,
                type_constraints => [ $sub_tc ],
            )
        );
    }

    $self->_build_form_from_fields(@fields);
}


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
