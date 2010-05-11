package Form::Functional::Reflector;
use Moose::Role;
use MooseX::Types::LoadableClass qw/ClassName/;
use namespace::autoclean;

requires qw/
    generate_form_from
/;

has form_class => (
    isa => ClassName,
    is => 'ro',
    coerce => 1,
    default => 'Form::Functional',
);

1;
