package Form::Functional;
# ABSTRACT: Reasonable Forms taking advantage of immutability and function data structures.
use Moose 0.90;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw(Str);
use MooseX::Types::Structured qw(Map);
use Form::Functional::Types qw(Field);
use MooseX::Types::LoadableClass qw(ClassName);
use namespace::autoclean;

has fields => (
    traits   => [qw(Hash)],
    isa      => Map[Str, Field],
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
