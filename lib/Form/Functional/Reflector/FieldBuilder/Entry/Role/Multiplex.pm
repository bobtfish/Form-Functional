package Form::Functional::Reflector::FieldBuilder::Entry::Role::Multiplex;

use MooseX::Role::Parameterized;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(ArrayRef);
use Form::Functional::Types qw(TypeConstraint);
use Form::Functional::Reflector::Types qw(FieldBuilderEntry Attribute);
use namespace::autoclean;

use aliased 'Form::Functional::Reflector::FieldBuilder::Result';

parameter entries_from => (
    is       => 'ro',
    isa      => (enum[qw(constructor builder)]),
    required => 1,
);

role {
    my ($p) = @_;

    has item_constraint => (
        isa => TypeConstraint,
        is => 'ro',
        required => 1,
        default => sub { Attribute },
    );

    has entries => (
        isa     => ArrayRef[FieldBuilderEntry],
        traits   => [qw(Array)],
        handles  => {
            entries => 'elements',
        },
        ($p->entries_from eq 'constructor'
             ? (required => 1)
             : (builder => '_build_entries',
                lazy    => 1,)),
    );

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

    method match => sub { 1 };

    method apply => sub {
        my ($self, $result, $item) = @_;

        for my $entry ($self->entries) {
            if ($entry->match($item)) {
                my $new_result = $entry->apply($result, $item);
                confess "FieldBuilder entry $entry->apply didn't return a new result"
                    unless $new_result;
                $result = $new_result;
            }
        }

        return $result;
    };

    method resolve => sub {
        my ($self, $item) = @_;

        confess(sprintf("Cannot resolve item '%s', is not a %s",
                        (defined $item ? $item : 'undef'), $self->item_constraint))
            unless $self->item_constraint->check($item);

        my $result = Result->new;
        $result = $self->apply($result, $item)
            if $self->match($item);

        # FIXME - Should we check the result is sane here?
        #         Should we check the result is sane inside the loop?
        return $result;
    };

    with 'Form::Functional::Reflector::FieldBuilder::Entry';
};

1;
