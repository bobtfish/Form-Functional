use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use MooseX::Types::Moose qw/Str/;
use Form::Functional;

use TestField;

my $form = Form::Functional->new(
    fields => [
        TestField->new(
            name => 'a_field',
            coerce => 0,
            required => 1,
            type_constraints => [ Str ],
        ),
    ],
);

ok $form, 'Have form';
can_ok $form, 'process';

{
    my $res = $form->process({});
    is_deeply {$res->values}, { a_field => undef }, 'No defined values';
}

my %in_vals = (
    a_field => 'a_value'
);

{
    my $res = $form->process(\%in_vals);
    ok $res, 'Have result';
    isa_ok $res, 'Form::Functional::Processed';

    my %out_vals = $res->values;

    is_deeply \%out_vals, \%in_vals, 'Output values as per input values';
}


done_testing;
