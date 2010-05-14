package Form::Functional::Field::WithInitValue::Compound;

use Moose::Role;
use MooseX::Types::Moose qw(HashRef);
use namespace::autoclean;

with 'Form::Functional::Field::WithInitValue' => { tc => HashRef };

1;
