package Form::Functional::Reflector::FieldBuilder::Entry::Role::Multiplex;

use Moose::Role;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw(ArrayRef);
use Form::Functional::Types qw(TypeConstraint);
use Form::Functional::Reflector::Types qw(FieldBuilderEntry Attribute);
use namespace::autoclean;

use aliased 'Form::Functional::Reflector::FieldBuilder::Result';

has item_constraint => (
    isa => TypeConstraint,
    is => 'ro',
    required => 1,
    default => sub { Attribute },
);

has entries => (
    isa     => ArrayRef[FieldBuilderEntry],
    lazy    => 1,
    builder => '_build_entries',
    traits   => [qw(Array)],
    handles  => {
        entries => 'elements',
    },
);

method _build_entries { [] }

around BUILDARGS => sub {
    my ($orig, $self, @args) = @_;
    my $args = $self->$orig(@args);
    if (exists $args->{entry}) {
        confess("entry and entries together not supported!")
            if exists $args->{entries};
        $args->{entries} = [ delete $args->{entry} ];
    }
    return $args;
};

method match ($item) { 1 }

method apply ($result, $item) {
    for my $entry ($self->entries) {
        if ($entry->match($item)) {
            my $new_result = $entry->apply($result, $item);
            confess "FieldBuilder entry $entry->apply didn't return a new result"
                unless $new_result;
            $result = $new_result;
        }
    }

    return $result;
}

method resolve ($item) {
    confess(sprintf("Cannot resolve item '%s', is not a %s",
                    (defined $item ? $item : 'undef'), $self->item_constraint))
        unless $self->item_constraint->check($item);

    my $result = Result->new;
    $result = $self->apply($result, $item)
        if $self->match($item);

    # FIXME - Should we check the result is sane here?
    #         Should we check the result is sane inside the loop?
    return $result;
}

with 'Form::Functional::Reflector::FieldBuilder::Entry';

1;
