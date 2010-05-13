use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Test::Exception;

use Form::Functional::Reflector::FieldBuilder;
use aliased 'MockFieldBuilderEntry' => 'Entry';

{
    my $fb = Form::Functional::Reflector::FieldBuilder->new;
    ok $fb, 'Have empty field builder';
    is_deeply $fb->entries, [], 'entries is empty';
    throws_ok { $fb->resolve } qr/Cannot resolve item 'undef', is not a Form::Functional::Reflector::Types::Attribute/,
        'Throws when no item passed';
    is_deeply $fb->resolve($fb->meta->find_attribute_by_name('entries')), {},
        'Pass attribute to empty builder returns empty field data';
}

done_testing;
