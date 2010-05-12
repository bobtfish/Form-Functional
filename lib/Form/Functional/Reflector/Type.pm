package Form::Functional::Reflector::Type;
use Moose;
use Method::Signatures::Simple;
use Moose::Util::TypeConstraints;
use MooseX::Types::Structured qw/ Dict Optional /;
use aliased 'Form::Functional::Field';
use Data::OptList qw/mkopt/;
use namespace::autoclean;

method generate_form_from ($type_or_name) {
    my $tc = blessed($type_or_name) ? $type_or_name : find_type_constraint($type_or_name);
    confess "Could not find type constraint named '$type_or_name', is is defined?"
        unless $tc;
    confess "$tc is not a Moose::Meta::TypeConstraint"
        unless $tc->isa('Moose::Meta::TypeConstraint');
    confess "$tc is not a Dict"
        unless $tc->is_a_type_of(Dict);

    # FIXME - Fugly! Deal with slurpy by setting the value to undef..
    my @constraints = @{ $tc->type_constraints };
    push(@constraints, undef) if scalar(@constraints) % 2;
    my %constraints = @constraints;

    my @fields;

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

with 'Form::Functional::Reflector';

__PACKAGE__->meta->make_immutable;
