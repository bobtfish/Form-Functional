package Form::Functional::Field::WithRenderData;
use Moose::Role;
use MooseX::Types::Moose qw/ HashRef /;
use namespace::autoclean;

has render_data => (
    is => 'ro',
    isa => HashRef,
    default => sub { {} },
);

1;
