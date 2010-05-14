use strict;
use warnings;

use Test::More;
use Test::Exception;

use aliased 'Form::Functional::Reflector::FieldBuilder::Result';

my $r1 = Result->new;
is scalar($r1->data), 0;

my $r2 = $r1->clone_and_set(foo => 'bar');
is_deeply {$r2->data}, {foo => 'bar'};
is $r2->get('foo'), 'bar';
isnt $r1, $r2;

my $r3 = $r2->clone_and_delete('foo');
is scalar($r3->data), 0;
isnt $r3, $r2;
isnt $r3, $r1;

my $r4 = $r2->clone_and_set(baz => { some => 'data'});
is_deeply {$r4->data}, { foo => 'bar', baz => { some => 'data'} };
is_deeply $r4->get('baz'), {some => 'data'};

throws_ok { $r4->clone_and_set( baz => { other => 'data'} ) }
    qr/annot merge/;

my $r5 = $r4->clone_and_merge_l( baz => { other => 'data' } );
is_deeply {$r5->data}, { foo => 'bar', baz => { some => 'data', other => 'data'} };

my $r6 = $r5->clone_and_merge_l( baz => { other => 'changed' } );
is_deeply {$r6->data}, { foo => 'bar', baz => { some => 'data', other => 'data'} };

my $r7 = $r6->clone_and_merge_r( baz => { other => 'changed' } );
is_deeply {$r7->data}, { foo => 'bar', baz => { some => 'data', other => 'changed'} };

my $r8 = Result->new->clone_and_merge_r( foo => { some => 'data'} );
is_deeply {$r8->data}, { foo => { some => 'data' }};

throws_ok { $r8->clone_and_set(foo => []) }
    qr/annot set key 'foo' to type ARRAY - it already holds a HASH/;

throws_ok { $r8->clone_and_set(foo => 'bar') }
    qr/annot set key 'foo' to type SCALAR - it already holds a HASH/;

done_testing;
