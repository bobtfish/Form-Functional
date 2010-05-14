package Form::Functional::Reflector::FieldBuilder::Entry::TypeConstraintFromAttribute;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw/ Any /;
use namespace::autoclean;

method match { 1 }

method apply ($result, $item) {
    my $tc = $item->has_type_constraint ? $item->type_constraint : Any;
    my $new_result = $result->clone_and_set(type_constraints => [$tc]);

    if ($tc->has_coercion) {
        $new_result = $new_result->clone_and_set(coerce => 1);
    }

    return $new_result;
}

with 'Form::Functional::Reflector::FieldBuilder::Entry';

__PACKAGE__->meta->make_immutable;
1;
