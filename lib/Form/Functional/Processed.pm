package Form::Functional::Processed;
# ABSTRACT: Represents the results of a form validation.

use Moose;
use Method::Signatures::Simple;
use List::AllUtils qw(part any);
use Form::Functional::Types qw(CompoundField InputValues Errors);
use MooseX::Types::Moose qw(HashRef);
use namespace::autoclean;

=attr field

The compound field which this process object reflects the values passed to.

In the normal case, this is the top-level form, however a form composed of
compound fields will have multiple processed objects, one for each compound field.

=cut

has field => (
    is       => 'ro',
    isa      => CompoundField,
    required => 1,
    handles  => {
        fields => 'fields',
    },
);

=attr input_values

The keys and values initially passed to the form for validation before any
coercions have taken place.

=cut

has input_values => (
    traits   => [qw(Hash)],
    isa      => InputValues,
    coerce   => 1,
    required => 1,
    handles  => {
        input_values => 'elements',
    },
);

=attr values

The values the form was validated with, after coercion.

=cut

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

=method values_for ($field_name)

The values passed to a named field.

=cut

method values_for ($name) {
    @{ $self->_values->{$name} };
}

=method values_exist_for ($field_name)

A predicate method returning true if any values were passed to the named field.

=cut

method values_exist_for ($name) {
    @{ $self->_values->{$name} || [] } > 0;
}

=attr results

Holds a hash of all the validation results.

=cut

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

=attr errors

Contains the errors which were generated during validation.

=method get_error_for_field ($field_name)

Returns the validation error / errors??? FIXME for the named field

=cut

# FIXME - How does this correspond with error_class in the field, as we have a type
#         constraint here which validates isa->('::Error'), but we in no way validate
#         that for the error class (as that is just a LoadableClass).
# FIXME - We have fuck all testsing of this structure
has errors => (
    traits   => [qw(Hash)],
    isa      => Errors,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_errors',
    handles  => {
        errors => 'elements',
        get_error_for_field => 'get',
    },
);

method BUILD {
    $self->errors;
}

method _build_values {
    my %inputs = $self->input_values;
    my %fields = $self->fields;

    my %values = map {
        exists $inputs{$_}
            ? do {
                my $k = $_;
                $fields{$_}->should_coerce
                    ? ($_ => [map { $fields{$k}->type_constraint->coerce($_) }
                                 @{ $inputs{ $_ } }])
                    : ($_ => $inputs{ $_ });
            }
            : ()
    } keys %fields;

    return \%values;
}

method _validate_field ($name, $field) {
    if (!$self->values_exist_for($name)) {
        return undef unless $field->is_required;
        return [$field->required_message($name, $self)];
    }

    my $ret = $field->validate({
        values => [$self->values_for($name)],
    });
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
    return { map {
        my @e = map {
            blessed $_ && $_->isa(__PACKAGE__)
                ? ($_->has_errors
                    ? { $_->errors }
                    : ())
                : $_
        } @{ $results{$_} };
        @e ? ($_ => \@e) : ()
    } keys %results };
}


=method has_errors

A predicate method which returns true if there were any validation errors in the form.

=cut

method has_errors {
    my %errors = $self->errors;
    !!keys %errors;
}

=method fields_with_errors

Returns a list of fields which had validation errors.

=cut

method fields_with_errors {
    my %errors = $self->errors;
    return keys %errors;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

    my $processed = $form->process({ values => { a_field => 'foo', another_field => 'bar' });
    if ($processed->has_errors) {
        my %errors
        foreach my $field_name ($processed->fields_with_errors) {
            my $error = $processed->get_error_for_field($field_name);
            warn("Field $field_name has error" . $error->message);
        }
    }

=head1 DESCRIPTION

Represents the result of trying to process a form with a set of values.

This includes the coercions performed on input values and any validation errors encountered
after coercion has taken place.

=cut
