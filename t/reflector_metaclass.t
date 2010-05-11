use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Test::Exception;

use TestReflectedClass;

use_ok 'Form::Functional::Reflector::MetaClass'
    or BAIL_OUT();

my $reflector = Form::Functional::Reflector::MetaClass->new;

lives_ok { isa_ok $reflector->generate_form_from('TestReflectedClass'), 'Form::Functional' };
lives_ok { isa_ok $reflector->generate_form_from(TestReflectedClass->meta), 'Form::Functional' };

done_testing;
