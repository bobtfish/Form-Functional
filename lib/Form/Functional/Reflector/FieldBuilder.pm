package Form::Functional::Reflector::FieldBuilder;
use Moose;
use MooseX::Types::Moose qw(ArrayRef);
use Form::Functional::Types qw(TypeConstraint);
use Form::Functional::Reflector::Types qw(FieldBuilderEntry Attribute);
use Method::Signatures::Simple;
use namespace::autoclean;

has entries => (
    is      => 'ro',
    isa     => ArrayRef[FieldBuilderEntry],
    lazy    => 1,
    builder => '_build_entries',
);

has item_constraint => (
    isa => TypeConstraint,
    is => 'ro',
    required => 1,
    default => sub { Attribute },
);

method _build_entries { [] }

method resolve ($item) {
    confess(sprintf("Cannot resolve item '%s', is not a %s",
            (defined $item ? $item : 'undef'), $self->item_constraint))
        unless $self->item_constraint->check($item);

    return {
        map { # FIXME - This bit sucks!
            $_->match($item)
                ? $_->apply($item)
                : ()
        } @{ $self->entries },
    };
}

__PACKAGE__->meta->make_immutable;
1;
