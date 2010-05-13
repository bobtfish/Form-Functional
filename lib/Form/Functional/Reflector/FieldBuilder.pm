package Form::Function::Reflector::FieldBuilder;
use Moose;
use MooseX::Types::Moose qw(ArrayRef);
use Form::Functional::Reflector::Types qw(FieldBuilderEntry);
use Method::Signatures::Simple;
use namespace::autoclean;

has entries => (
    is      => 'ro',
    isa     => ArrayRef[FieldBuilderEntry],
    lazy    => 1,
    builder => '_build_entries',
);

method _build_entries { [] }

method resolve ($attr) {
    return {
        map { # FIXME - This bit sucks!
            $_->match($attr)
                ? $_->apply($attr)
                : ()
        } @{ $self->entries },
    };
}

__PACKAGE__->meta->make_immutable;
