use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Test::Exception;

use TestTypes qw/ UCOnly UCOnlyTwo UCOnlyNoCoercion /;

use aliased 'Form::Functional::FieldBuilder';

throws_ok {
    FieldBuilder->make({
        as   => ['Discrete'],
        with => {
            coerce           => 1,
            required         => 1,
            type_constraints => [ UCOnlyNoCoercion ],
        },
    });
} qr/Cannot coerce/, 'Cannot coerce message if no coercion on TC';

throws_ok {
    FieldBuilder->make({
        as   => ['Discrete'],
        with => {
            coerce           => 1,
            required         => 1,
            type_constraints => [ UCOnlyNoCoercion ],
        },
    })
} qr/UCOnlyNoCoercion/, 'Cannot coerce message tells you TC name';

throws_ok {
    FieldBuilder->make({
        as => ['Discrete'],
        with => {
            coerce           => 1,
            required         => 1,
            type_constraints => [ UCOnly, UCOnlyTwo ],
        },
    })
} qr/more than one type constraint/, 'More than one TC without explicit coercion message';

my $form = FieldBuilder->make({
    as => ['Compound'],
    with => {
        fields => [
            a_field => FieldBuilder->make({
                as => ['Discrete'],
                with => {
                    coerce           => 1,
                    required         => 1,
                    type_constraints => [ UCOnly ],
                },
            }),
        ],
        required         => 1,
        type_constraints => [],
    },
});

my $res = $form->process({ values => { a_field => 'foobar' } });
can_ok $res, 'values';
is_deeply {$res->values}, {a_field => ['FOOBAR']},
    'Data coerced as expected';

                          # Type   TypeCoercion      CodeRef
foreach my $coercion_from (UCOnly, UCOnly->coercion, UCOnly->coercion->_compiled_type_coercion) {
    my $form = FieldBuilder->make({
        as => ['Compound'],
        with => {
            fields => [
                a_field => FieldBuilder->make({
                    as => ['Discrete'],
                    with => {
                        coercion         => UCOnly->coercion,
                        required         => 1,
                        type_constraints => [ UCOnlyNoCoercion ],
                    },
                }),
            ],
            required         => 1,
            type_constraints => [],
        },
    });

    my $res = $form->process({ values => { a_field => 'foobar' } });
    is_deeply {$res->values}, {a_field => ['FOOBAR']},
        'Data coerced as expected';
}

done_testing;
