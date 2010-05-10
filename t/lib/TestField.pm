package TestField;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

with 'Form::Functional::Field';

__PACKAGE__->meta->make_immutable;
