package Form::Functional::Reflector::FieldBuilder::Entry::Role::MatchOnly;
use Moose::Role;
use namespace::autoclean;

sub apply {}

with 'Form::Functional::Reflector::FieldBuilder::Entry';

1;
