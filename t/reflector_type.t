use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Test::Exception;
use Test::Moose;

use MooseX::Types::Structured qw/ Dict Optional slurpy /;
use MooseX::Types::Moose qw/ Str Int HashRef /;

use_ok 'Form::Functional::Reflector::Type'
    or BAIL_OUT();

my $reflector = Form::Functional::Reflector::Type->new;

throws_ok { $reflector->generate_output_from('ThisTypeDoesNotExist') }
    qr/not find type constraint named 'ThisTypeDoesNotExist'/, 'Non existant type throws';

throws_ok { $reflector->generate_output_from(bless {}, 'ThisTypeDoesNotExist') }
    qr/is not a Moose::Meta::TypeConstraint/, 'Not a type constraint throws';

throws_ok { $reflector->generate_output_from(Str) }
    qr/is not a Dict/, 'Not a Dict type constraint throws';

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

    my $form; does_ok $form = $reflector->generate_output_from($tc), 'Form::Functional::Field::Compound';

    my @ok = (
        { req_int => 1, req_str => 'foo' },
        { req_int => 1, req_str => 'foo', opt_int => 1, opt_str => 'bar' },
        { req_int => 1, req_str => 'foo', complex => { foo => 'quux', bar => 3 } },
    );

    foreach my $try (@ok) {
        # FIXME - should also test that we have the expected data (and that random crap is removed)
        ok $tc->check($try), 'Can check ok with TC';
        my $result = $form->process({ values => $try });
        use Devel::Dwarn;
        local $Data::Dumper::Maxdepth = 4;
        ok !$result->has_errors, 'No errors'
            or Dwarn $result;
    }

    my @fail = (
        {},
        { req_int => 'foo', req_str => 'foo' },
        { req_int => 1, req_str => 'foo', opt_int => 'bar', opt_str => {} },
        { req_int => 1, req_str => 'foo', complex => { foo => {}, bar => 'quux' } },
    );

    foreach my $try (@fail) {
        ok !$tc->check($try), 'Cannot check ok with TC';
        my $result = $form->process({ values => $try });
        use Devel::Dwarn;
        local $Data::Dumper::Maxdepth = 5;
        ok $result->has_errors, 'Has errors'
            or Dwarn [$try, $result];
    }
}

done_testing;
