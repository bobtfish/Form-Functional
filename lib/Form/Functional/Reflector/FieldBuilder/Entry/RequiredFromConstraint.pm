package Form::Functional::Reflector::FieldBuilder::Entry::RequiredFromConstraint;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Structured qw/Optional/;
use namespace::autoclean;

method match { 1 }

method apply ($result, $item) {
    my $tc = $item->[1];
    my $required = !$tc->is_a_type_of(Optional);
    if (!$required) { # FIXME - This here is a massive, massive bucket of fail!
                      #         we should entirely treat the input data structure as immutable!!!
        $item->[1] = $tc->type_parameter;
    }
    $result->clone_and_merge_r(with => {required => $required});
}

with 'Form::Functional::Reflector::FieldBuilder::Entry';

__PACKAGE__->meta->make_immutable;
1;