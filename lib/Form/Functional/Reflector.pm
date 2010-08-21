package Form::Functional::Reflector;
use Moose::Role;
use Method::Signatures::Simple;
use MooseX::Types::LoadableClass qw/LoadableClass/;
use Form::Functional::Reflector::Types qw/ FieldOutputter FieldComposer FieldBuilderEntry TypeMap /;
use namespace::autoclean;

requires qw/
    validate_reflectee
    get_fields_from_reflectee
/;

has field_builder_class => (
    is => 'ro',
    isa => LoadableClass,
    default => 'Form::Functional::Reflector::FieldBuilder::Default',
    coerce => 1,
);

has field_builder => (
    isa => FieldBuilderEntry,
    is => 'ro',
    required => 1,
    default => sub {
        my $self = shift;
        $self->field_builder_class->new
    },
    handles => {
        resolve_field => 'resolve',
    },
);

has field_outputter_class => (
    isa => LoadableClass,
    is => 'ro',
    default => 'Form::Functional::Reflector::FieldOutputter::Form',
    coerce => 1,
);

has field_outputter => (
    is => 'ro',
    isa => FieldOutputter,
    default => sub {
        my $self = shift;
        $self->field_outputter_class->new;
    },
    handles => {
        _output_field => 'output_field',
    },
    lazy => 1,
);

has field_composer_class => (
    isa => LoadableClass,
    is => 'ro',
    default => 'Form::Functional::Reflector::FieldComposer::Form',
    coerce => 1,
);

has field_composer => (
    is => 'ro',
    isa => FieldComposer,
    default => sub {
        my $self = shift;
        $self->field_composer_class->new;
    },
    handles => {
        build_form_from_fields => 'output_from_fields',
    },
    lazy => 1,
);

method generate_output_from ($reflectee) {
    $reflectee = $self->validate_reflectee($reflectee);
    # FIXME - Ordering
    $self->build_form_from_fields(
        map { $self->build_field($_) }
        $self->get_fields_from_reflectee($reflectee)
    );
}

method build_field ($field) {
    #use Devel::Dwarn;
    #Dwarn \%data;
    $self->_output_field($self->resolve_field($field))
}

1;

__END__

=head1 SYNOPSIS

=head1 ATTRIBUTES

=attr form_class

=attr field_builder

=head1 METHODS

=method build_field

=method build_form_from_fields

=method generate_form_from

=cut
