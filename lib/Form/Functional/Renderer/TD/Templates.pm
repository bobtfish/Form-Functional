package Form::Functional::Renderer::TD::Templates;
use strict;
use warnings;
use Method::Signatures::Simple;
use Template::Declare::Tags;
use Moose::Autobox 0.11;
use namespace::clean -except => [qw/ meta /];

use base 'Template::Declare';

sub make_form (&) {
    my ($cb) = @_;
    smart_tag_wrapper {
        my %params = @_;
        my @fields = $params{form}->fields;
        my %extra;
        if ($params{render_data}) {
            foreach my $name (qw/ method action /) {
                $extra{$name} = $params{render_data}->{$name} if $params{render_data}->{$name};
            }
        }

        form {
            attr { %extra, %{ $params{attr} || {} } };
            legend { $params{render_data}->{legend} } if $params{render_data}->{legend};
            while (my ($name, $field) = splice @fields, 0, 2) {
                $cb->($name, $field);
            }
        };
    };
}

sub make_input (;&) {
    my ($cb) = @_;
    smart_tag_wrapper {
        my %params = @_;
        input {
            attr {
                type => 'text',
                name => $params{name},
                $cb ? (value => $cb->()) : (),
            };
        };
    };
}

template field => sub {
    my ($self, $form, $name, $field) = @_;
    with (
        name  => $name,
        field => $field,
    ), make_input;
};

template form => sub {
    my ($self, $form) = @_;

    my %data = (
        form => $form,
        $form->can('render_data') ? (render_data => $form->render_data) : ()
    );

    with (
        %data
    ), make_form {
        my ($name, $field) = @_;
        show field => $form, $name, $field;
    };
};

template processed_field => sub {
    my ($self, $processed, $name, $field) = @_;
    with (
        name  => $name,
        field => $field,
    ), make_input {
        ($processed->values_for($name))[0] # FIXME!
            if $processed->values_exist_for($name);
    };
};

template processed => sub {
    my ($self, $processed) = @_;

    my %data = (
        form => $processed,
        $processed->field->can('render_data') ? (render_data => $processed->field->render_data) : ()
    );

    with (
        %data
    ), make_form {
        my ($name, $field) = @_;
        show processed_field => $processed, $name, $field;
    };
};

1;
