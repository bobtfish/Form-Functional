package Form::Functional::Processed;
# ABSTRACT: Represents the results of a form validation.

use Moose;
use Method::Signatures::Simple;
use List::AllUtils qw(part any);
use Form::Functional::Types qw(CompoundField InputValues);
use MooseX::Types::Moose qw(HashRef);
use namespace::autoclean;

has field => (
    is       => 'ro',
    isa      => CompoundField,
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

has results => (
    traits   => [qw(Hash)],
    isa      => HashRef,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_results',
    handles  => {
        _results => 'elements',
    },
);

has errors => (
    traits   => [qw(Hash)],
    isa      => HashRef,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_errors',
    handles  => {
        errors => 'elements',
    },
);

method BUILD {
    $self->errors;
}

method _build_values {
    my %inputs = $self->input_values;
    my %fields = $self->fields;

    my %values = map {
        my $k = $_;
        $fields{$_}->should_coerce
            ? ($_ => [map { $fields{$k}->type_constraint->coerce($_) } @{ $inputs{ $_ } }])
            : ($_ => $inputs{ $_ });
    } keys %fields;

    return \%values;
}

method _validate_field ($name, $field) {
    if (!$self->values_exist_for($name)) {
        return undef unless $field->is_required;
        return [$field->required_message($name, $self)];
    }

    my $ret = $field->validate($self->values_for($name));
    return $ret;
}

method _build_results {
    my %fields = $self->fields;

    my %errors = map {
        my $msgs = $self->_validate_field($_ => $fields{$_});
        defined $msgs ? ($_ => $msgs) : ();
    } keys %fields;

    return \%errors;
}

method _build_errors {
    my %results = $self->_results;
    my %errors = map {
        my @e = map {
            blessed $_ && $_->isa(__PACKAGE__)
                ? ($_->has_errors
                    ? { $_->errors }
                    : ())
                : $_
        } @{ $results{$_} };
        @e ? ($_ => \@e) : ()
    } keys %results;

    return \%errors;
}

method has_errors {
    my %errors = $self->errors;
    !!keys %errors;
}

method fields_with_errors {
    my %errors = $self->errors;
    return keys %errors;
}

__PACKAGE__->meta->make_immutable;

1;
