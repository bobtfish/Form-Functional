use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Devel::Dwarn;

use Test::More;
use Test::Exception;

use Class::MOP::Class;
use TestReflectedClass;
use TestReflectedClassCompound;

use_ok 'Form::Functional::Reflector::MetaClass'
    or BAIL_OUT();

{
    package Non::Moose::Class;
    use strict;
    use warnings;

    our $VERSION = 0.1;
}

Class::MOP::Class->create(
    'CMOPClass' => (
        version => 0.1,
    )
);

my $reflector = Form::Functional::Reflector::MetaClass->new;

throws_ok { $reflector->generate_form_from('This::Class::Does::Not::Exist') }
    qr/is is loaded/, 'Error for non-existent/non-loaded classes';

throws_ok { $reflector->generate_form_from('Non::Moose::Class') }
    qr/ould not find metaclass/, 'Error for non-moose (POOP) classes';

throws_ok { $reflector->generate_form_from('CMOPClass') }
    qr/does not have a Moose metaclass/, 'Error for non-moose (CMOP) classes';

{
    my $form;

    lives_ok { isa_ok $form = $reflector->generate_form_from('TestReflectedClass'), 'Form::Functional' };
    lives_ok { isa_ok $reflector->generate_form_from(TestReflectedClass->meta), 'Form::Functional::Form' };

    my @ok = (
        { req_int => 1, req_str => 'foo' },
        { req_int => 1, req_str => 'foo', opt_int => 1, opt_str => 'bar' },
        { req_int => 1, req_str => 'foo', random => 'crap' },
    );

    foreach my $try (@ok) {
        # FIXME - should also test that we have the expected data (and that random crap is removed)
        lives_ok { TestReflectedClass->new($try) } 'Can construct real class';
        my $result = $form->process({ values => $try });
        ok !$result->has_errors, 'No errors';
    }

    my @fail = (
        {},
        { req_int => 'foo', req_str => 'foo' },
        { req_int => 1, req_str => 'foo', opt_int => 'bar', opt_str => {} },
    );

    foreach my $try (@fail) {
        dies_ok { TestReflectedClass->new($try) } 'Cannot construct real class';
        my $result = $form->process({ values => $try });
        ok $result->has_errors, 'Has errors';
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
        # FIXME - should also test that we have the expected data (and that random crap is removed)
        lives_ok { TestReflectedClassCompound->new($try) } 'Can construct real compound class';
        my $result = $form->process({ values => $try });
        local $Data::Dumper::Maxdepth = 4;
        ok !$result->has_errors
            or Dwarn [$try, [$result->errors]];
    }
}

done_testing;
