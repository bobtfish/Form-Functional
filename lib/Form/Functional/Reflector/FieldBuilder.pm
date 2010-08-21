package Form::Functional::Reflector::FieldBuilder;

use Moose;
use namespace::autoclean;

with 'Form::Functional::Reflector::FieldBuilder::Entry::Role::Multiplex' => {
    entries_from => 'constructor',
};

__PACKAGE__->meta->make_immutable;

1;
