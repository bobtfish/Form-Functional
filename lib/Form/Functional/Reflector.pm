package Form::Functional::Reflector;
use Moose::Role;
use MooseX::Method::Signatures;
use MooseX::Types::LoadableClass qw/ClassName/;
use Form::Functional::Reflector::Types qw/ FieldBuilderEntry TypeMap /;
use namespace::autoclean;

use aliased 'Form::Functional::Reflector::FieldBuilder::Default' => 'DefaultFieldBuilder';
use aliased 'Form::Functional::FieldBuilder' => 'FormFieldBuilder';

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
    #use Devel::Dwarn;
    #Dwarn \%data;
                                                                                # FIXME!!!
    return keys(%data) ? (delete $data{name} => FormFieldBuilder->make({%data, as => ['Discrete']})) : ();
}

method build_form_from_fields (@fields) {
    FormFieldBuilder->make({
        as => ['Compound'],
        with => {
            fields => \@fields,
            required         => 1,
            type_constraints => [],
        },
    });
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
