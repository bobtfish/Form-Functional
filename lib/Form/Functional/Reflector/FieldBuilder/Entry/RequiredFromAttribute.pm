package Form::Functional::Reflector::FieldBuilder::Entry::RequiredFromAttribute;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

method match { 1 }

method apply ($result, $item) {
    my $required = ($item->has_builder || $item->has_default || !$item->is_required) ? 0 : 1;
    $result->clone_and_set(required => $required);
}

with 'Form::Functional::Reflector::FieldBuilder::Entry';

__PACKAGE__->meta->make_immutable;
1;
