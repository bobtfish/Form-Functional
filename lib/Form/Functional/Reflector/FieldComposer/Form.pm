package Form::Functional::Reflector::FieldComposer::Form;

use Moose;
use namespace::autoclean;

use aliased 'Form::Functional::FieldBuilder' => 'FormFieldBuilder';

sub output_from_fields {
    my ($self, @fields) = @_;
                                                                                # FIXME!!!
    FormFieldBuilder->make({
        as => ['Compound'],
        with => {
            fields => \@fields,
            required         => 1,
            type_constraints => [],
        },
    });
}

with 'Form::Functional::Reflector::FieldComposer';

__PACKAGE__->meta->make_immutable;
1;
