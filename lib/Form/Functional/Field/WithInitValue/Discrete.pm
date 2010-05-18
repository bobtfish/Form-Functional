package Form::Functional::Field::WithInitValue::Discrete;
# ABSTRACT: A role for fields with discrete initial values.

use Moose::Role;
use MooseX::Types::Moose qw(Value Undef);
use namespace::autoclean;

with 'Form::Functional::Field::WithInitValue' => { tc => Value | Undef };

1;
