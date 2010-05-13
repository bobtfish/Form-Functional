use strict;
use warnings;
use Test::More;

use Form::Functional;
use Form::Functional::Field;

my $form = Form::Functional->new({
    fields => [
        foo => Form::Functional::Field->with_traits(qw(Select Single))->new({
            valid_options    => [qw(affe birne tiger)],
            type_constraints => [],
            coerce           => 0,
            required         => 0,
        }),
        bar => Form::Functional::Field->with_traits(qw(Select))->new({
            valid_options    => ['a' .. 'f'],
            type_constraints => [],
            coerce           => 0,
            required         => 1,
        }),
    ],
    required         => 1,
    type_constraints => [],
});

isa_ok($form, 'Form::Functional');

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
