package Form::Functional::Reflector::FieldBuilder::Entry::Role::MatchOnly;

use Moose::Role;
use Method::Signatures::Simple;
use namespace::autoclean;

method apply ($result, $item) { $result }

with 'Form::Functional::Reflector::FieldBuilder::Entry';

1;
