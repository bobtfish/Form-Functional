package Form::Functional::Reflector::FieldOutputter;

use Moose;
use namespace::autoclean;

use aliased 'Form::Functional::FieldBuilder' => 'FormFieldBuilder';

sub output_field {
    my ($self, $fieldbuilder_result) = @_;
    my %data = $fieldbuilder_result->data;
                                                                                # FIXME!!!
    return keys(%data) ? (delete $data{name} => FormFieldBuilder->make({%data, as => ['Discrete']})) : ();
}

__PACKAGE__->meta->make_immutable;
