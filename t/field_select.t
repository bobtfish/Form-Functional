use strict;
use warnings;
use Test::More;

use Form::Functional::Form;
use Form::Functional::FieldBuilder;

my $form = Form::Functional::Form->new({
    fields => [
        foo => Form::Functional::FieldBuilder->make({
            as   => [qw(Discrete Select Single)],
            with => {
                valid_options    => [qw(affe birne tiger)],
                type_constraints => [],
                coerce           => 0,
                required         => 0,
            },
        }),
        bar => Form::Functional::FieldBuilder->make({
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
});

isa_ok($form, 'Form::Functional::Form');

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
