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
    handles  => {
        fields => 'fields',
    },
);

has input_values => (
    traits   => [qw(Hash)],
    isa      => HashRef,
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
    handles  => {
        values           => 'elements',
        value_for        => 'get',
        value_exists_for => 'exists',
    },
);

has _results => (
    traits   => [qw(Hash)],
    isa      => HashRef,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build__results',
    handles  => {
        _results => 'elements',
    },
);

method BUILD {
    $self->_results;
}

method _build_values {
    my %inputs = $self->input_values;

    my %values = map {
        $_->should_coerce
            ? ($_->name => $_->type_constraint->coerce($inputs{ $_->name }))
            : ($_->name => $inputs{ $_->name });
    } $self->fields;

    return \%values;
}

method _validate_field ($field) {
    if (!$self->value_exists_for($field->name)) {
        return undef unless $field->is_required;
        return [[$field->required_message]];
    }

    my $msgs = $field->type_constraint->validate_all($self->value_for($field->name));
    return $msgs if defined $msgs;

    return undef;
}

method _build__results {
    my %results = map {
        my $msgs = $self->_validate_field($_);
        defined $msgs ? ($_->name => $msgs) : ();
    } $self->fields;

    return \%results;
}

__PACKAGE__->meta->make_immutable;

1;
