use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Test::Exception;

use MooseX::Types::Structured qw/ Dict Optional slurpy /;
use MooseX::Types::Moose qw/ Str Int HashRef /;

use_ok 'Form::Functional::Reflector::Type'
    or BAIL_OUT();

foreach my $extra ( [], [slurpy(Dict)] ) {
    my $tc = Dict[
        req_str => Str,
        req_int => Int,
        opt_str => Optional[Str],
        opt_int => Optional[Int],
        complex => Optional[Dict[
            foo => Str,
            bar => Int,
        ]],
        @$extra
    ];

    my $reflector = Form::Functional::Reflector::Type->new;
    my $form; isa_ok $form = $reflector->generate_form_from($tc), 'Form::Functional';

    my @ok = (
        { req_int => 1, req_str => 'foo' },
        { req_int => 1, req_str => 'foo', opt_int => 1, opt_str => 'bar' },
        { req_int => 1, req_str => 'foo', complex => { foo => 'quux', bar => 3 } },
    );

    foreach my $try (@ok) {
        ok $tc->check($try), 'Can check ok with TC';
        my $result = $form->process($try);
        ok !$result->has_errors, 'No errors';
    }

    my @fail = (
        {},
        { req_int => 'foo', req_str => 'foo' },
        { req_int => 1, req_str => 'foo', opt_int => 'bar', opt_str => {} },
        { req_int => 1, req_str => 'foo', complex => { foo => {}, bar => 'quux' } },
    );

    foreach my $try (@fail) {
        ok !$tc->check($try), 'Cannot check ok with TC';
        my $result = $form->process($try);
        ok $result->has_errors, 'Has errors';
    }
}

done_testing;
