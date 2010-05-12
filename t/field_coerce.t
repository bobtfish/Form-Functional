use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;

use TestTypes qw/ UCOnly /;
use Form::Functional;

use aliased 'Form::Functional::Field';

my $form = Form::Functional->new(
    fields => [
        a_field => Field->new(
            coerce => 1,
            required => 1,
            type_constraints => [ UCOnly ],
        ),
    ],
    required         => 1,
    type_constraints => [],
);

my $res = $form->process({a_field => 'foobar'});
can_ok $res, 'values';
is_deeply {$res->values}, {a_field => ['FOOBAR']},
    'Data coerced as expected';

done_testing;
