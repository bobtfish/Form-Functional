use strict;
use warnings;
use Test::More;

use Form::Functional;
use Form::Functional::Field;

my $form = Form::Functional->new({
    fields => [
        Form::Functional::Field->with_traits(qw(Select Single))->new({
            name             => 'foo',
            valid_options    => [qw(affe birne tiger)],
            type_constraints => [],
            coerce           => 0,
            required         => 0,
        }),
        Form::Functional::Field->with_traits(qw(Select))->new({
            name             => 'bar',
            valid_options    => ['a' .. 'f'],
            type_constraints => [],
            coerce           => 0,
            required         => 1,
        }),
    ],
});

isa_ok($form, 'Form::Functional');

{
    my $res = $form->process({ foo => ['moo'] });
    ok(exists { $res->_errors }->{$_}) for qw/foo bar/;
}

{
    my $res = $form->process({ foo => ['birne'] });
    ok(!exists { $res->_errors }->{foo});
}

{
    my $res = $form->process({ foo => ['birne', 'affe'] });
    ok(exists { $res->_errors }->{foo});
}

done_testing;
