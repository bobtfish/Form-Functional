package Form::Functional::Processed;

use Moose;
use Method::Signatures::Simple;
use Form::Functional::Types qw(Form);
use MooseX::Types::Moose qw(HashRef);
use namespace::autoclean;

has form => (
    is       => 'ro',
    isa      => Form,
    required => 1,
);

has input_values => (
    traits   => [qw(Hash)],
    isa      => HashRef,
    required => 1,
    provides => {
        input_values => 'elements',
    },
);

has values => (
    traits   => [qw(Hash)],
    isa      => HashRef,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_values',
    provides => {
        values           => 'elements',
        value_for        => 'get',
        value_exists_for => 'exists',
    },
);

method BUILD {
}

method _build_values {
    my %inputs = $self->input_values;

    my %values = map {
        $_->should_coerce
            ? ($_->name => $_->type_constraint->coerce($inputs{ $_->name }))
            : ($_->name => $inputs{ $_->name });
    } $self->form->fields

    return \%values;
}

method _validate_field ($field) {
    if (!$self->value_exists_for($field->name)) {
        return undef unless $field->is_required;

        ...;
    }

    my $value = $self->value_for($field->name);
    if (defined (my $msg = $field->type_constraint->validate($value))) {
    }

    return undef;
}

__PACKAGE__->meta->make_immutable;

1;
