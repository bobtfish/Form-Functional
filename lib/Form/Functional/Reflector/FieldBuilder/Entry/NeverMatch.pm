package Form::Functional::Reflector::FieldBuilder::Entry::NeverMatch;
use Moose;
use namespace::autoclean;

sub match { 0 };

sub apply { confess("Should never be called") }

with 'Form::Functional::Reflector::FieldBuilder::Entry';

__PACKAGE__->meta->make_immutable;
1;
