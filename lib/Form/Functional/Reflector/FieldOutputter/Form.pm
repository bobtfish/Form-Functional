package Form::Functional::Reflector::FieldOutputter::Form;

use Moose;
use namespace::autoclean;

use aliased 'Form::Functional::FieldBuilder' => 'FormFieldBuilder';

sub output_field {
    my ($self, $fieldbuilder_result) = @_;
    my %data = $fieldbuilder_result->data;
                                                                                # FIXME!!!
    return keys(%data) ? (delete $data{name} => FormFieldBuilder->make({%data, as => ['Discrete']})) : ();
}

with 'Form::Functional::Reflector::FieldOutputter';

__PACKAGE__->meta->make_immutable;
