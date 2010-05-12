package TestReflectedClass;
use Moose;
use MooseX::Types::Moose qw/Str Int/;
use namespace::autoclean;

has req_str => ( is => 'ro', required => 1, isa => Str );
has req_int => ( is => 'ro', required => 1, isa => Int );

has opt_str => ( is => 'ro', required => 0, isa => Str );
has opt_int => ( is => 'ro', required => 0, isa => Int );

has with_default => ( is => 'ro', default => 5, required => 1, );
has with_builder => ( is => 'ro', builder => '_build_with_builder', required => 1 );

sub _build_with_builder { 5 }

__PACKAGE__->meta->make_immutable;
1;
