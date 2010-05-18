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
        #use Data::Dumper;
        #local $Data::Dumper::Maxdepth = 1;
        #warn Dumper \%params;
        my @fields = $params{form}->fields;
        my %extra;
        if ($params{render_data}) {
            foreach my $name (qw/ method action id class /) {
                $extra{$name} = $params{render_data}->{$name} if $params{render_data}->{$name};
            }
        }

        form {
            attr {
                %extra,
                id => $params{form_id},
                %{ $params{attr} || {} }
            };
            legend { $params{render_data}->{legend} } if $params{render_data}->{legend};
            while (my ($name, $field) = splice @fields, 0, 2) {
                $cb->($name, $field, $params{form_id});
            }
        };
    };
}

sub make_input (;&) {
    my ($cb) = @_;
    smart_tag_wrapper {
        my %params = @_;
        #use Data::Dumper;
        #local $Data::Dumper::Maxdepth = 2;
        #warn Dumper \%params;
        my $field_id = $params{form_id} . '_' . $params{name};
        label {
            attr {
                for => $field_id
            }
            my $name = ucfirst $params{name};
            $name =~ s/_/ /g;
            $name;
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
    my ($self, $form, $name, $field, $form_id) = @_;
    with (
        name  => $name,
        field => $field,
        form_id => $form_id,
    ), make_input;
};

sub _build_form_data {
    my ($self, $form, $render_data) = @_;
    my %data = (
        form => $form,
        render_data => $render_data,
    );
    $data{form_id} = $render_data->{id} if $render_data->{id};
    return %data;
}

template processed_field => sub {
    my ($self, $processed, $name, $field, $form_id) = @_;
    with (
        name  => $name,
        field => $field,
        form_id => $form_id,
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
};

template form => sub {
    my ($self, $form) = @_;

    with (
        form_id => "form_" . refaddr($form),
        $self->_build_form_data($form, $form->can('render_data') ? $form->render_data : {}),
    ),
    make_form {
        my ($name, $field, $form_id) = @_;
        show field => $form, $name, $field, $form_id;
    };
};

template processed_form => sub {
    my ($self, $processed) = @_;

    my %render_data = $self->_build_form_data($processed, $processed->field->can('render_data') ? $processed->field->render_data : {});
    with (
        form_id => "form_" . refaddr($processed->field),
        %render_data,
    ),
    make_form {
        my ($name, $field, $form_id) = @_;
        show processed_field => $processed, $name, $field, $form_id;
    };
};

1;
