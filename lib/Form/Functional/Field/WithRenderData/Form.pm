package Form::Functional::Field::WithRenderData::Form;
use Moose::Role;
use MooseX::Types::Structured qw/ Dict /;
use MooseX::Types::Moose qw/ Str /;
use namespace::autoclean;

with 'Form::Functional::Field::WithRenderData' => {
    type_constraint => Dict[
        action => Str,
    ],
};

1;
