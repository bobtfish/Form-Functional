use strict;
use warnings;
use Test::More;

use aliased 'Form::Functional::FieldBuilder';

my $form = FieldBuilder->make({
    as => ['Compound'],
    with => {
        type_constraints => [],
        required         => 1,
        fields           => [
            foo => FieldBuilder->make({
                as   => ['Discrete'],
                with => {
                    type_constraints => [],
                    required         => 1,
                },
            }),
            bar => FieldBuilder->make({
                as   => ['Discrete'],
                with => {
                    type_constraints => [],
                    required         => 0,
                },
            }),
        ],
    },
});

my $with_init = $form->clone_with_init_value({ bar => 23 });
is_deeply({ $with_init->init_value }, { bar => 23 });
is($with_init->find_field_by_name('bar')->init_value, 23);
ok(!$with_init->find_field_by_name('foo')->can('init_value'));

my $processed = $with_init->process({ values => { foo => 42 } });
ok(!$processed->has_errors);

done_testing;
