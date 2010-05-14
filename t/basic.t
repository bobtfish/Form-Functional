use strict;
use warnings;

use Test::More;
use Test::Exception;
use MooseX::Types::Moose qw/Str/;
use Form::Functional::Form;

use aliased 'Form::Functional::FieldBuilder';

my $field = FieldBuilder->make({
    as   => ['Discrete'],
    with => {
        coerce => 0,
        required => 1,
        type_constraints => [ Str ],
    },
});

my $form = Form::Functional::Form->new(
    fields => [
        a_field => $field,
        another_field => FieldBuilder->make({
            as   => ['Discrete'],
            with => {
                coerce => 0,
                required => 0,
                type_constraints => [ Str ],
            },
        }),
    ],
    required         => 1,
    type_constraints => [],
);

ok $form, 'Have form';
can_ok $form, 'process';

is $form->find_field_by_name('a_field'), $field, 'find field';

dies_ok(sub { $form->process });

isa_ok $form->process({ values => {} }), 'Form::Functional::Processed';

{
    my $res = $form->process({ values => {} });
    is_deeply {$res->values}, { }, 'No values';
}

{
    my %in_vals = (a_field => 'a_value');
    my %exp_out_vals = map { ($_ => [$in_vals{$_}]) } keys %in_vals;

    my $res = $form->process({ values => \%in_vals });
    ok $res, 'Have result';
    isa_ok $res, 'Form::Functional::Processed';

    is_deeply {$res->values}, \%exp_out_vals, 'Output values as per input values';
    ok $res->values_exist_for('a_field'), 'Values exist for a_field';
    ok !$res->values_exist_for('another_field'), 'Values do not exist for another_field';
    ok !$res->values_exist_for('this_field_not_in_this_form'), 'Values do not exist for field not in this form';

    $res = $form->process({ values => { %in_vals, some => 'other', random => 'crap' } });
    is_deeply {$res->values}, \%exp_out_vals, 'Output values ignore unknown fields data';
}


done_testing;
