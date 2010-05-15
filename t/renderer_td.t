use strict;
use warnings;

use Test::More;
use Test::Moose;
use HTML::TreeBuilder;

use MooseX::Types::Moose qw/ Int Str /;

use aliased 'Form::Functional::FieldBuilder';
use aliased 'Form::Functional::Renderer::TD' => 'Renderer';

my $form = FieldBuilder->make({
    as => ['Compound', 'WithRenderData'],
    with => {
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
        render_data => {
            method => 'POST',
            action => 'http://www.foo.com/bar',
            legend => 'My form',
        }
    },
});
my $renderer = Renderer->new;
ok $renderer, 'Have renderer';
does_ok $renderer, 'Form::Functional::Renderer';

{
    my $out = $renderer->render($form);
    ok !ref($out), 'Out is plain string';
    test_output($out)->delete;
}

# Generate some errors
my $processed = $form->process({ values => { int_field => 'foo' } });

{
    my $out = $renderer->render($processed);
    ok !ref($out), 'Out is plain string';
    my $tree = test_output($out);
    is $tree->look_down('_tag' => 'input', sub {shift->attr('name') eq 'int_field'})->attr('value'), 'foo';
    $tree->delete;
}

sub test_output {
    my $out = shift;
    diag $out;
    my $tree = HTML::TreeBuilder->new_from_content($out);
    my $form = $tree->look_down('_tag', 'form');
    ok $form->as_HTML;
    is $form->attr('method'), 'POST';
    is $form->attr('action'), 'http://www.foo.com/bar';
    my $legend = $form->look_down('_tag', 'legend');
    is $legend->content->[0], 'My form';
    my $int_f_tag = $form->look_down('_tag', 'input', sub {shift->attr('name') eq 'int_field'});
    ok $int_f_tag->as_HTML;
    is $int_f_tag->attr('type'), 'text';
    my $str_f_tag = $form->look_down('_tag', 'input', sub {shift->attr('name') eq 'str_field'});
    ok $str_f_tag->as_HTML;
    is $str_f_tag->attr('type'), 'text';
    return $tree;
}

done_testing;
