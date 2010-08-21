package Form::Functional::Reflector::FieldBuilder::Entry::NameFromConstraint;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

method match { 1 }

method apply ($result, $item) {
    $result->clone_and_set(name => $item->[0]);
}

with 'Form::Functional::Reflector::FieldBuilder::Entry';

__PACKAGE__->meta->make_immutable;
1;