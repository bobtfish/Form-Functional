package Form::Functional::Field::Select;
# ABSTRACT: A select list field within a form

use Moose::Role;
use Method::Signatures::Simple;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(ArrayRef Str);
use namespace::autoclean;

=attr valid_options

A list of options valid for this select field.

=cut

has valid_options => (
    traits   => [qw(Array)],
    isa      => ArrayRef[Str],
    required => 1,
    handles  => {
        valid_options => 'elements',
    },
);

has _options_tc => (
    is      => 'ro',
    isa     => 'Moose::Meta::TypeConstraint',
    lazy    => 1,
    builder => '_build_options_tc',
);

method _build_options_tc {
    my $tc = enum [$self->valid_options];
}

around type_constraints => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig(@_), $self->_options_tc;
};

1;
