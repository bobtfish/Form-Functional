use strict;
use warnings;

use Test::More;
use Test::Moose;

use MooseX::Types::Moose qw/ Int Str /;
use Form::Functional::Form;

use aliased 'Form::Functional::FieldBuilder';
use aliased 'Form::Functional::Renderer::TD' => 'Renderer';

my $form = Form::Functional::Form->new(
    required         => 1,
    type_constraints => [],
    fields           => [
        int_field => FieldBuilder->make({
            as => ['Discrete'],
            with => {
                coerce           => 0,
                required         => 1,
                type_constraints => [ Int ],
            },
        }),
        str_field => FieldBuilder->make({
            as => ['Discrete'],
            with => {
                coerce           => 0,
                required         => 1,
                type_constraints => [ Str ],
            },
        }),
    ],
);
my $renderer = Renderer->new;
ok $renderer, 'Have renderer';
does_ok $renderer, 'Form::Functional::Renderer';

{
    my $out = $renderer->render($form);
    ok !ref($out), 'Out is plain string';
    diag $out;
}

# Generate some errors
my $processed = $form->process({ values => { int_field => 'foo' } });

{
    my $out = $renderer->render($processed);
    ok !ref($out), 'Out is plain string';
    diag $out;
}

done_testing;
