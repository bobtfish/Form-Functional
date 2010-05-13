package Form::Functional::Reflector::FieldBuilder::Default;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

extends 'Form::Functional::Reflector::FieldBuilder';

__PACKAGE__->meta->make_immutable;
1;
