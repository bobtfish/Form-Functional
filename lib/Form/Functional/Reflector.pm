package Form::Functional::Reflector;
use Moose::Role;
use Method::Signatures::Simple;
use MooseX::Types::LoadableClass qw/ClassName/;
use Form::Functional::Reflector::Types qw/ FieldBuilderEntry TypeMap /;
use namespace::autoclean;

use aliased 'Form::Functional::Reflector::FieldBuilder::Default' => 'DefaultFieldBuilder';
use aliased 'Form::Functional::Reflector::FieldOutputter';
use aliased 'Form::Functional::Reflector::FieldComposer';

requires qw/
    validate_reflectee
    get_fields_from_reflectee
/;

has field_builder => (
    isa => FieldBuilderEntry,
    is => 'ro',
    required => 1,
    default => sub { DefaultFieldBuilder->new },
    handles => {
        resolve_field => 'resolve',
    },
);

has field_outputter => (
    is => 'ro',
    required => 1,
    default => sub {
        FieldOutputter->new;
    },
    handles => {
        _output_field => 'output_field',
    },
);

has field_composer => (
    is => 'ro',
    required => 1,
    default => sub {
        FieldComposer->new;
    },
    handles => {
        build_form_from_fields => 'output_from_fields',
    },
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
