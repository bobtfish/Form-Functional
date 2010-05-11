use strict;
use warnings;
use Test::More;
use Form::Functional;

my $form = Form::Functional->new(
    fields           => [],
    required         => 1,
    type_constraints => [],
);

ok $form, 'Have form';
can_ok $form, 'process';

my $res = $form->process({});
ok $res, 'Have result';
isa_ok $res, 'Form::Functional::Processed';

done_testing;
