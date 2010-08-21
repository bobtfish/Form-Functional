package Form::Functional::Reflector::FieldOutputter::Rx;

use Moose;
use namespace::autoclean;

sub output_field {
    my ($self, $fieldbuilder_result) = @_;
    my %data = $fieldbuilder_result->data;
    return {} unless scalar %data;
    my $key = delete $data{with}{required} ? 'required' : 'optional';
    my $tc = delete $data{with}{type_constraints}[0];
    my $type = '//any';
    if ($tc) {
        $type = '//str' if ($tc->name eq 'Str');
        $type = '//int' if ($tc->name eq 'Int');
    }
    return {
        $key => {
            delete $data{name} => $type,
        },
    };
}

with 'Form::Functional::Reflector::FieldOutputter';

__PACKAGE__->meta->make_immutable;
