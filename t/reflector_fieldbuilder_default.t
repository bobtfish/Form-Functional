use strict;
use warnings;

use Test::More;
use List::AllUtils qw/natatime/;
use Devel::Dwarn;

use MooseX::Types::Moose qw/Str/;

use aliased 'Form::Functional::Reflector::FieldBuilder::Default' => 'FieldBuilder';
use aliased 'Form::Functional::Reflector::FieldBuilder::Result';

my @tests = (
    Moose::Meta::Attribute->new( foo => ( is => 'ro', required => 1, isa => Str) )
        => { name => 'foo', required => 1, type_constraints => [ Str ] },
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
