package MockFieldBuilderEntry;
use Moose;
use MooseX::Types::Moose qw/ CodeRef /;
use namespace::autoclean;

foreach my $attr (qw/ match apply /) {
    my $accessor = "_$attr";
    has $accessor => ( init_arg => $attr, isa => CodeRef, is => 'ro', required => 1 );
    __PACKAGE__->meta->add_method($attr => sub { my $self = shift; $self->$accessor->($self, @_) });
}

with 'Form::Functional::Reflector::FieldBuilder::Entry';

__PACKAGE__->meta->make_immutable;
1;
