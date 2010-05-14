package Form::Functional::Reflector::FieldBuilder;
use Moose;
use MooseX::Types::Moose qw(ArrayRef);
use Form::Functional::Types qw(TypeConstraint);
use Form::Functional::Reflector::Types qw(FieldBuilderEntry Attribute);
use Method::Signatures::Simple;
use namespace::autoclean;

use aliased 'Form::Functional::Reflector::FieldBuilder::Result';

# FIXME - I think we should probably have the same sort of deal here as we have
#         with compound fields in the main F::F and F::F::F::Compound, as really
#         the field builder is just a specialised case of a FieldBuild::Entry
#         with additional behaviour. Make it so!

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

has entries => (
    isa     => ArrayRef[FieldBuilderEntry],
    lazy    => 1,
    builder => '_build_entries',
    traits   => [qw(Array)],
    handles  => {
        entries => 'elements',
    },
);

has item_constraint => (
    isa => TypeConstraint,
    is => 'ro',
    required => 1,
    default => sub { Attribute },
);

method _build_entries { [] }

method resolve ($item) {
    #use Devel::Dwarn;
    #local $Data::Dumper::Maxdepth = 2;
    #Dwarn $item;
    confess(sprintf("Cannot resolve item '%s', is not a %s",
            (defined $item ? $item : 'undef'), $self->item_constraint))
        unless $self->item_constraint->check($item);

    my $result = Result->new;
    foreach my $entry ($self->entries) {
        if ($entry->match($item)) {
            my $new_result = $entry->apply($result, $item);
            $result = $new_result if $new_result;
        }
    }
    # FIXME - Should we check the result is sane here?
    #         Should we check the result is sane inside the loop?
    return $result;
}

__PACKAGE__->meta->make_immutable;
1;
