package Form::Functional::Reflector::FieldBuilder::Entry::TypeConstraintFromAttribute;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw/ Any /;
use namespace::autoclean;

method match { 1 }

method apply ($result, $item) {
    my $tc = $item->has_type_constraint ? $item->type_constraint : Any;
    $result->clone_and_set(type_constraints => [$tc]);
}

with 'Form::Functional::Reflector::FieldBuilder::Entry';

__PACKAGE__->meta->make_immutable;
1;
