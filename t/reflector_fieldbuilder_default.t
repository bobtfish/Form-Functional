use strict;
use warnings;

use Test::More;
use List::AllUtils qw/natatime/;
use Devel::Dwarn;

use MooseX::Types::Moose qw/Str Any/;
use MooseX::Types::Structured qw/ Dict /;

use aliased 'Form::Functional::Reflector::FieldBuilder::Default' => 'FieldBuilder';
use aliased 'Form::Functional::Reflector::FieldBuilder::Result';

my @tests = (
    Moose::Meta::Attribute->new( foo => ( is => 'ro', required => 1, isa => Str) )
        => { name => 'foo', with => { required => 1, type_constraints => [ Str ] } },
    Moose::Meta::Attribute->new( foo => ( is => 'ro', required => 0, isa => Str) )
        => { name => 'foo', with => { required => 0, type_constraints => [ Str ] } },
    Moose::Meta::Attribute->new( foo => ( is => 'ro', required => 0) )
        => { name => 'foo', with => { required => 0, type_constraints => [ Any ] } },
    Moose::Meta::Attribute->new( foo => ( is => 'ro', required => 1, isa => Str, default => "Hi") )
        => { name => 'foo', with => { required => 0, type_constraints => [ Str ] } },
);

my $fb = FieldBuilder->new;

my $it = natatime 2, @tests;
while (my ($in, $out) = $it->()) {
    my $res = $fb->resolve($in);
    isa_ok $res, Result, 'Got a field builder result';
    is_deeply {$res->data}, $out, 'Result data is as expected'
        or Dwarn {$res->data};
}

done_testing;
