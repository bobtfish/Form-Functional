package Form::Functional;
# ABSTRACT: Reasonable Forms taking advantage of immutability and function data structures.
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw(ArrayRef);
use Form::Functional::Types qw(Field);
use MooseX::Types::LoadableClass qw(ClassName);
use namespace::autoclean;

has fields => (
    traits   => [qw(Array)],
    isa      => ArrayRef[Field],
    required => 1,
    handles  => {
        fields => 'elements',
    },
);

has processed_class => (
    is      => 'ro',
    isa     => ClassName,
    coerce  => 1,
    default => 'Form::Functional::Processed',
    handles => {
        _new_processed => 'new',
    },
);

method process ($values) {
    return $self->_new_processed({
        form         => $self,
        input_values => $values,
    });
}

__PACKAGE__->meta->make_immutable;

1;
