package Form::Functional::Renderer::TD::Templates;
use strict;
use warnings;
use Method::Signatures::Simple;
use Template::Declare::Tags;
use Moose::Autobox 0.11;
use Scalar::Util qw/refaddr/;
use namespace::clean -except => [qw/ meta /];

use base 'Template::Declare';

sub make_form (&) {
    my ($cb) = @_;
    smart_tag_wrapper {
        my %params = @_;
        my @fields = $params{form}->fields;
        my %extra;
        if ($params{render_data}) {
            foreach my $name (qw/ method action id class /) {
                $extra{$name} = $params{render_data}->{$name} if $params{render_data}->{$name};
            }
        }
        $extra{id} = "form_" . refaddr($params{form}) unless $extra{id};

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
        my $field_id = 'form_XXXX_' . $params{name};
        label {
            attr {
                for => $field_id
            }
            ucfirst $params{name};
        }
        input {
            attr {
                id => $field_id,
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
    span {
        with (
            name  => $name,
            field => $field,
        ), make_input {
            ($processed->values_for($name))[0] # FIXME!
                if $processed->values_exist_for($name);
        };
        if (my $errors = {$processed->errors}->{$name}) {
            foreach my $error ($errors->flatten) {
                div {
                    attr {
                        class => 'error'
                    };
                    $error->message;
                };
            };
        }
    }
};

template processed => sub {
    my ($self, $processed) = @_;

#    use Devel::Dwarn;
#    local $Data::Dumper::Maxdepth = 4;
#    Dwarn $processed;

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
