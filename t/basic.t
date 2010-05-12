use strict;
use warnings;

use Test::More;
use MooseX::Types::Moose qw/Str/;
use Form::Functional;

use aliased 'Form::Functional::Field';

my $form = Form::Functional->new(
    fields => [
        a_field => Field->new(
            coerce => 0,
            required => 1,
            type_constraints => [ Str ],
        ),
    ],
    required         => 1,
    type_constraints => [],
);

ok $form, 'Have form';
can_ok $form, 'process';

isa_ok $form->process, 'Form::Functional::Processed';

{
    my $res = $form->process({});
    is_deeply {$res->values}, { a_field => undef }, 'No defined values';
}

{
    my %in_vals = (a_field => 'a_value');
    my %exp_out_vals = map { ($_ => [$in_vals{$_}]) } keys %in_vals;

    my $res = $form->process({%in_vals});
    ok $res, 'Have result';
    isa_ok $res, 'Form::Functional::Processed';

    is_deeply {$res->values}, \%exp_out_vals, 'Output values as per input values';

    $res = $form->process({%in_vals, some => 'other', random => 'crap'});
    is_deeply {$res->values}, \%exp_out_vals, 'Output values ignore unknown fields data';
}


done_testing;
