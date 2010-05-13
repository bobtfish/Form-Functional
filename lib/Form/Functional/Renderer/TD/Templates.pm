package Form::Functional::Renderer::TD::Templates;
use strict;
use warnings;
use Method::Signatures::Simple;
use Template::Declare::Tags;
use Moose::Autobox 0.11;
use namespace::clean -except => [qw/ meta /];

use base 'Template::Declare';

template field_without_value => sub {
    my ($self, $form, $name, $field) = @_;
    show field_with_value => $form, $name, $field, q{};
};

template field_with_value => sub {
    my ($self, $form, $name, $field, $value) = @_;
    input {
        attr {
            type => 'text',
            name => $name,
        };
        $value;
    };
};

template form => sub {
    my ($self, $form, $values) = @_;
    my @fields = $form->fields;

    form {
        while (my ($name, $field) = splice(@fields, 0, 2)) {
            if (exists $values->{$name}) {
                my $val = $values->{$name};
                $val = $val->[0] if ref($val) eq 'ARRAY'; # FIXME!
                show field_with_value => $form, $name, $field, $val;
            }
            else {
                show field_without_value => $form, $name, $field;
            }
        }
    };
};

1;
