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
        form {
            attr { %{ $params{attr} || {} } };
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

    with (
        form => $form,
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
    with (
        form => $processed,
    ), make_form {
        my ($name, $field) = @_;
        show processed_field => $processed, $name, $field;
    };
};

1;
