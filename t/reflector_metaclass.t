use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Devel::Dwarn;

use Test::More;
use Test::Exception;

use TestReflectedClass;
use TestReflectedClassCompound;

use_ok 'Form::Functional::Reflector::MetaClass'
    or BAIL_OUT();

my $reflector = Form::Functional::Reflector::MetaClass->new;

{
    my $form;

    lives_ok { isa_ok $form = $reflector->generate_form_from('TestReflectedClass'), 'Form::Functional' };
    lives_ok { isa_ok $reflector->generate_form_from(TestReflectedClass->meta), 'Form::Functional' };

    my @ok = (
        { req_int => 1, req_str => 'foo' },
        { req_int => 1, req_str => 'foo', opt_int => 1, opt_str => 'bar' },
        { req_int => 1, req_str => 'foo', random => 'crap' },
    );

    foreach my $try (@ok) {
        lives_ok { TestReflectedClass->new($try) } 'Can construct real class';
        my $result = $form->process($try);
        my @errors = $result->_errors;
        is scalar(@errors), 0, 'No errors';
    }

    my @fail = (
        {},
        { req_int => 'foo', req_str => 'foo' },
        { req_int => 1, req_str => 'foo', opt_int => 'bar', opt_str => {} },
    );

    foreach my $try (@fail) {
        dies_ok { TestReflectedClass->new($try) } 'Cannot construct real class';
        my $result = $form->process($try);
        my @errors = $result->_errors;
        ok scalar(@errors) > 0, 'Has errors';
    }
}

{
    my $form;
    lives_ok { isa_ok $form = $reflector->generate_form_from('TestReflectedClassCompound'), 'Form::Functional' };

    my @ok = (
        { req_int => 1, req_str => 'foo', delegate => { req_int => 1, req_str => 'foo' } },
        { req_int => 1, req_str => 'foo', delegate => { req_int => 1, req_str => 'foo', pt_int => 1, opt_str => 'bar' } },
        { req_int => 1, req_str => 'foo', delegate => { req_int => 1, req_str => 'foo', random => 'crap' } },
        { req_int => 1, req_str => 'foo', delegate => { req_int => 1, req_str => 'foo' }, random => 'crap' },
    );

    foreach my $try (@ok) {
        lives_ok { TestReflectedClassCompound->new($try) } 'Can construct real compound class';
        my $result = $form->process($try);
        my @errors = $result->_errors;
        is scalar(@errors), 0, 'No errors'
            or Dwarn [$try, \@errors];
    }
}

done_testing;
