package Form::Functional::Field::WithInitValue::Discrete;

use Moose::Role;
use MooseX::Types::Moose qw(Value Undef);
use namespace::autoclean;

with 'Form::Functional::Field::WithInitValue' => { tc => Value | Undef };

1;
