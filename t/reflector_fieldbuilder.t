use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Test::Exception;

use aliased 'Form::Functional::Reflector::FieldBuilder';
use aliased 'MockFieldBuilderEntry' => 'Entry';

my $test_attr = FieldBuilder->meta->find_attribute_by_name('entries');
{
    my $fb = FieldBuilder->new;
    ok $fb, 'Have empty field builder';
    is_deeply [$fb->entries], [], 'entries is empty';
    throws_ok { $fb->resolve } qr/Cannot resolve item 'undef', is not a Form::Functional::Reflector::Types::Attribute/,
        'Throws when no item passed';
    is_deeply $fb->resolve($test_attr), {},
        'Pass attribute to empty builder returns empty field data';
}

{
    my $apply_called = 0;
    my $apply = sub { $apply_called++; (); };
    foreach my $exp (0..1) {
        my $fb = FieldBuilder->new(entries => [
            Entry->new(
                match => sub { $exp },
                apply => $apply,
            ),
        ]);
        is_deeply $fb->resolve($test_attr), {}, 'No values in field hash for ' . $exp;
        is $apply_called, $exp, 'apply_called is ' . $exp;
    }
}

{
    my $fb = FieldBuilder->new(entries => [
        Entry->new(
            match => sub { 1 },
            apply => sub { ( foo => 'bar' )},
        ),
    ]);
    is_deeply $fb->resolve($test_attr), { foo => 'bar' },
        'apply returning simple list';
}

{
    my $fb = FieldBuilder->new(entries => [
        Entry->new(
            match => sub { 1 },
            apply => sub { ( foo => 'bar' )},
        ),
        Entry->new(
            match => sub { 1 },
            apply => sub { ( baz => 'quux' )},
        ),
    ]);
    is_deeply $fb->resolve($test_attr), { baz => 'quux' },
        'resolve with apply overriding previous data';
}

{
    my $fb = FieldBuilder->new(entries => [
        Entry->new(
            match => sub { 1 },
            apply => sub { ( foo => 'bar' )},
        ),
        Entry->new(
            match => sub { 1 },
            apply => sub {
                my ($self, $fields, $item) = @_;
                ( %$fields, baz => 'quux' )},
        ),
    ]);
    is_deeply $fb->resolve($test_attr), { foo => 'bar', baz => 'quux' },
        'resolve with apply merging previous data';
}

done_testing;
