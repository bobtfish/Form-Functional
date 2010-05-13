package MockFieldBuilderEntry;
use Moose;
use MooseX::Types::Moose qw/ Bool CodeRef /;
use namespace::autoclean;

has match => ( isa => Bool, is => 'ro', required => 1 );
has apply => ( isa => CodeRef, is => 'ro', required => 1 );

with 'Form::Functional::Reflector::FieldBuilder::Entry';

__PACKAGE__->meta->make_immutable;
1;
