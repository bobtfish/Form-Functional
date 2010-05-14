package Form::Functional::Reflector;
use Moose::Role;
use MooseX::Method::Signatures;
use MooseX::Types::LoadableClass qw/ClassName/;
use Form::Functional::Reflector::Types qw/ FieldBuilder TypeMap /;
use namespace::autoclean;

use aliased 'Form::Functional::Reflector::FieldBuilder::Default' => 'DefaultFieldBuilder';
use aliased 'Form::Functional::FieldBuilder' => 'FormFieldBuilder';

requires qw/
    validate_reflectee
    get_fields_from_reflectee
/;

has form_class => (
    isa => ClassName,
    is => 'ro',
    coerce => 1,
    default => 'Form::Functional::Form',
);

has field_builder => (
    isa => FieldBuilder,
    is => 'ro',
    required => 1,
    default => sub { DefaultFieldBuilder->new },
    handles => {
        resolve_field => 'resolve',
    },
);

method generate_form_from ($reflectee) {
    $reflectee = $self->validate_reflectee($reflectee);
    # FIXME - Ordering
    $self->build_form_from_fields(
        map { $self->build_field($_) }
        $self->get_fields_from_reflectee($reflectee)
    );
}

method build_field ($field) {
    my %data = $self->resolve_field($field)->data;
    use Devel::Dwarn;
    Dwarn \%data;
                                                                                # FIXME!!!
    return keys(%data) ? (delete $data{name} => FormFieldBuilder->make({%data, as => ['Discrete']})) : ();
}

method build_form_from_fields (@fields) {
    $self->form_class->new(
        fields => \@fields,
        required         => 1,
        type_constraints => [],
    );
}

1;
