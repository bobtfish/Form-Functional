package Form::Functional::Processed;

use Moose;
use Method::Signatures::Simple;
use Form::Functional::Types qw(Form InputValues);
use MooseX::Types::Moose qw(HashRef);
use namespace::autoclean;

has form => (
    is       => 'ro',
    isa      => Form,
    required => 1,
    handles  => {
        fields => 'fields',
    },
);

has input_values => (
    traits   => [qw(Hash)],
    isa      => InputValues,
    coerce   => 1,
    required => 1,
    handles  => {
        input_values => 'elements',
    },
);

has values => (
    traits   => [qw(Hash)],
    isa      => HashRef,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_values',
    reader   => '_values',
    handles  => {
        values => 'elements',
    },
);

method values_for ($name) {
    @{ $self->_values->{$name} };
}

method values_exist_for ($name) {
    @{ $self->_values->{$name} || [] } > 0;
}

has errors => (
    traits   => [qw(Hash)],
    isa      => HashRef,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_errors',
    handles  => {
        _errors => 'elements',
    },
);

method BUILD {
    $self->_errors;
}

method _build_values {
    my %inputs = $self->input_values;

    my %values = map {
        $_->should_coerce
            ? ($_->name => [map { $_->type_constraint->coerce($_) } @{ $inputs{ $_->name } }])
            : ($_->name => $inputs{ $_->name });
    } $self->fields;

    return \%values;
}

method _validate_field ($field) {
    if (!$self->values_exist_for($field->name)) {
        return undef unless $field->is_required;
        return [$field->required_message($self)];
    }

    $field->validate($self->values_for($field->name));
}

method _build_errors {
    my %errors = map {
        my $msgs = $self->_validate_field($_);
        defined $msgs ? ($_->name => $msgs) : ();
    } $self->fields;

    return \%errors;
}

__PACKAGE__->meta->make_immutable;

1;
