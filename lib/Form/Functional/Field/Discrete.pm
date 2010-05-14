package Form::Functional::Field::Discrete;

use Moose::Role;
use Method::Signatures::Simple;
use namespace::autoclean;

method _build__with_init_value_trait { 'Form::Functional::Field::WithInitValue::Discrete' }

method validate ($args) {
    my @values = @{ $args->{values} };
    my @msgs = map {
        $self->_new_error({
            message                => $_->[0],
            failed_type_constraint => $_->[1],
        })
    } map { @{ $_ } } grep defined, map {
        $self->type_constraint->validate_all($_)
    } @values;

    return unless @msgs;
    return \@msgs;
}

method clone_with_init_value ($value) {
    my $clone = $self->clone;
    $self->_with_init_value_trait->apply(
        $clone,
        rebless_params => {
            init_value => $value,
        },
    );
}

with 'Form::Functional::FieldAtom';

1;
