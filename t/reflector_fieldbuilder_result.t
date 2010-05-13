use strict;
use warnings;

use Test::More;

use aliased 'Form::Functional::Reflector::FieldBuilder::Result';

my $r1 = Result->new;
is scalar($r1->data), 0;

my $r2 = $r1->clone_and_set(foo => 'bar');
is_deeply {$r2->data}, {foo => 'bar'};
isnt $r1, $r2;

my $r3 = $r2->clone_and_delete('foo');
is scalar($r3->data), 0;
isnt $r3, $r2;
isnt $r3, $r1;

done_testing;
