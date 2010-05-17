use strict;
use warnings;

use Test::More;
use Test::Moose;
use HTML::TreeBuilder;
use Moose::Autobox;
use Scalar::Util qw/refaddr/;

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
    test_output($out, $form)->delete;
}

# Generate some errors
my $processed = $form->process({ values => { int_field => 'foo' } });

{
    my $out = $renderer->render($processed);
    ok !ref($out), 'Out is plain string';
    my $tree = test_output($out, $processed->field);
    is $tree->look_down('_tag' => 'input', sub {shift->attr('name') eq 'int_field'})->attr('value'), 'foo';
    $tree->delete;
}

sub test_output {
    my ($out, $form_instance) = @_;
    my $form_id = 'form_' . refaddr($form_instance);
    diag $out;
    my $tree = HTML::TreeBuilder->new_from_content($out);
    my $form = $tree->look_down('_tag', 'form');
    ok $form->as_HTML;
    is $form->attr('id'), $form_id;
    is $form->attr('method'), 'POST';
    is $form->attr('action'), 'http://www.foo.com/bar';

    my $legend = $form->look_down('_tag', 'legend');
    is $legend->content->[0], 'My form';

    my $int_f_tag = $form->look_down('_tag', 'input', sub {shift->attr('name') eq 'int_field'});
    ok $int_f_tag->as_HTML;
    is $int_f_tag->attr('id'), $form_id . '_int_field';
    is $int_f_tag->attr('type'), 'text';

    my $int_f_label = $form->look_down('_tag', 'label', sub {shift->attr('for') eq $form_id . '_int_field'});
    ok $int_f_label->as_HTML;
    is [$int_f_label->content_list]->join(''), 'Int field';

    my $str_f_tag = $form->look_down('_tag', 'input', sub {shift->attr('name') eq 'str_field'});
    ok $str_f_tag->as_HTML;
    is $str_f_tag->attr('id'), $form_id . '_str_field';
    is $str_f_tag->attr('type'), 'text';

    my $str_f_label = $form->look_down('_tag', 'label', sub {shift->attr('for') eq $form_id . '_str_field'});
    ok $str_f_label->as_HTML;
    is [$str_f_label->content_list]->join(''), 'Str field';

    return $tree;
}

done_testing;
