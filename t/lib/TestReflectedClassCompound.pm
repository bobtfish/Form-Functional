package TestReflectedClassCompound;
use Moose;
use MooseX::Types::Moose qw/Str Int HashRef/;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

has req_str => ( is => 'ro', required => 1, isa => Str );
has req_int => ( is => 'ro', required => 1, isa => Int );

class_type 'TestReflectedClass';
coerce 'TestReflectedClass', from HashRef, via { TestReflectedClass->new($_) };
has delegate => ( is => 'ro', required => 1, isa => 'TestReflectedClass', coerce => 1 );

__PACKAGE__->meta->make_immutable;
1;
