package Form::Functional::Field::Form;
# ABSTRACT: Reasonable Forms taking advantage of immutability and functional data structures
use Moose::Role 0.90;
use namespace::autoclean;

with 'Form::Functional::Field::Compound' => {
    fields => {
        required => 1,
    },
};

1;
