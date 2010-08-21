use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Devel::Dwarn;

use Test::More;
use Test::Exception;
use Test::Moose;

use Class::MOP::Class;
use TestReflectedClass;
use TestReflectedClassCompound;

use_ok 'Form::Functional::Reflector::MetaClass'
    or BAIL_OUT();

my $reflector = Form::Functional::Reflector::MetaClass->new(
    field_outputter_class => 'Form::Functional::Reflector::FieldOutputter::Rx',
    field_composer_class => 'Form::Functional::Reflector::FieldComposer::Rx',
);

my $data = $reflector->generate_output_from( 'TestReflectedClass' );

is_deeply $data, {
  optional => {
    opt_int => "//int",
    opt_str => "//str",
    with_builder => "//any",
    with_default => "//any"
  },
  required => {
    req_int => "//int",
    req_str => "//str"
  },
  type => "//rec"
}, 'Generate Rx schema';

done_testing;
