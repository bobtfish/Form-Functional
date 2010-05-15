use strict;
use warnings;
use Test::More;
use Test::Moose;

use aliased 'Form::Functional::FieldBuilder';

my $form = FieldBuilder->make({
    as => ['Form'],
    with => {
        fields => [
            foo => FieldBuilder->make({
                as   => [qw(Discrete Select Single)],
                with => {
                    valid_options    => [qw(affe birne tiger)],
                    type_constraints => [],
                    coerce           => 0,
                    required         => 0,
                },
            }),
            bar => FieldBuilder->make({
                as   => [qw(Discrete Select)],
                with => {
                    valid_options    => ['a' .. 'f'],
                    type_constraints => [],
                    coerce           => 0,
                    required         => 1,
                },
            }),
        ],
        required         => 1,
        type_constraints => [],
    },
});

does_ok($form, 'Form::Functional::Field::Form');

{
    my $res = $form->process({ values => { foo => ['moo'] } });
    ok(exists { $res->_results }->{$_}) for qw/foo bar/;
}

{
    my $res = $form->process({ values => { foo => ['birne'] } });
    ok(!exists { $res->_results }->{foo});
}

{
    my $res = $form->process({ values => { foo => ['birne', 'affe'] } });
    ok(exists { $res->_results }->{foo});
}

done_testing;
