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
    is_deeply {$fb->resolve($test_attr)->data}, {},
        'Pass attribute to empty builder returns empty field data';
}

{
    my $apply_called = 0;
    my $apply = sub { $apply_called++; my ($self, $result, $item) = @_; return $result; };
    foreach my $exp (0..1) {
        my $fb = FieldBuilder->new(entries => [
            Entry->new(
                match => sub { $exp },
                apply => $apply,
            ),
        ]);
        is_deeply {$fb->resolve($test_attr)->data}, {}, 'No values in field hash for ' . $exp;
        is $apply_called, $exp, 'apply_called is ' . $exp;
    }
}

{
    my $fb = FieldBuilder->new(entries => [
        Entry->new(
            match => sub { 1 },
            apply => sub {
                my ($self, $result, $item) = @_;
                $result->clone_and_set( foo => 'bar' )
            },
        ),
    ]);
    is_deeply {$fb->resolve($test_attr)->data}, { foo => 'bar' },
        'apply returning simple list';
}

{
    my $fb = FieldBuilder->new(entries => [
        Entry->new(
            match => sub { 1 },
            apply => sub {
                my ($self, $result, $item) = @_;
                $result->clone_and_set( foo => 'bar' );
            },
        ),
        Entry->new(
            match => sub { 1 },
            apply => sub {
                my ($self, $result, $item) = @_;
                $result->clone_and_set(foo => 'quux' );
            },
        ),
    ]);
    is_deeply {$fb->resolve($test_attr)->data}, { foo => 'quux' },
        'resolve with apply overriding previous data';
}

{
    my $fb = FieldBuilder->new(entries => [
        Entry->new(
            match => sub { 1 },
            apply => sub {
                my ($self, $result, $item) = @_;
                $result->clone_and_set( foo => 'bar' );
            },
        ),
        Entry->new(
            match => sub { 1 },
            apply => sub {
                my ($self, $result, $item) = @_;
                $result->clone_and_set(baz => 'quux' );
            },
        ),
    ]);
    is_deeply {$fb->resolve($test_attr)->data}, { foo => 'bar', baz => 'quux' },
        'resolve with apply merging previous data';
}

{
    my $fb = FieldBuilder->new(entries => [
        Entry->new(
            match => sub { 1 },
            apply => sub {
                my ($self, $result, $item) = @_;
                $result->clone_and_set( foo => 'bar' )->clone_and_set( 'bar' => 'baz');
            },
        ),
        Entry->new(
            match => sub { 1 },
            apply => sub {
                my ($self, $result, $item) = @_;
                $result->clone_and_delete('foo');
            },
        ),
    ]);
    is_deeply {$fb->resolve($test_attr)->data}, { bar => 'baz' },
        'resolve with apply deleting previous data';
}

done_testing;
