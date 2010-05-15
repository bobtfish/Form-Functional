use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use MooseX::Types::Moose qw/Str/;

use aliased 'Form::Functional::FieldBuilder';
use TestTypes qw/ UCOnly /;

my $form = FieldBuilder->make({
    as => ['Form'],
    with => {
        fields => [
            a_field => FieldBuilder->make({
                as   => ['Discrete'],
                with => {
                    coerce           => 0,
                    required         => 1,
                    type_constraints => [ Str, UCOnly ],
                },
            }),
        ],
        required         => 1,
        type_constraints => [],
    },
});

ok $form, 'Have form';
can_ok $form, 'process';

{
    my $res = $form->process({ values => {} });
    is_deeply {$res->values}, { }, 'No defined values';
}

my %in_vals = (
    a_field => 'AVALUE'
);

{
    my $res = $form->process({ values => \%in_vals });
    ok $res, 'Have result';
    isa_ok $res, 'Form::Functional::Processed';

    my %out_vals = $res->values;

    is scalar($res->_results), 0, 'No validation failures';
    is_deeply \%out_vals, { map { ($_ => [$in_vals{$_}]) } keys %in_vals }, 'Output values as per input values';
}

%in_vals = (
    a_field => 'avalue'
);

{
    my $res = $form->process({ values => \%in_vals });
    ok $res, 'Have result';
    isa_ok $res, 'Form::Functional::Processed';

    my %out_vals = $res->values;

    ok $res->has_errors;
    my %results = $res->_results;
    is scalar(keys %results), 1, '1 field failed';
    my $error = delete $results{a_field};
    is scalar(keys %results), 0, 'failed field was the expected field';
    is ref($error), 'ARRAY', 'Error is an array ref';
    like $error->[0]->message, qr/Validation failed for 'TestTypes::UCOnly'/, 'Correct message (1/2)';
    like $error->[0]->message, qr/with value avalue/, 'Correct message (2/2)';
    ok $error->[0]->has_failed_type_constraint;

    is_deeply \%out_vals, { map { ($_ => [$in_vals{$_}]) } keys %in_vals }, 'Output values as per input values';
}

done_testing;
