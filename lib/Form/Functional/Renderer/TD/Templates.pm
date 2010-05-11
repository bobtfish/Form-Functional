package Form::Functional::Renderer::TD::Templates;
use strict;
use warnings;
use Method::Signatures::Simple;
use Template::Declare::Tags;
use Moose::Autobox 0.11;
use namespace::clean -except => [qw/ meta /];

use base 'Template::Declare';

template form => sub {
    my ($self, $form, $data) = @_;
    my @fields = $form->fields;
                   # I'm deeply uncomfortable with this being in here..
    my $values = { ($form->can('values') ? $form->values : ()), %{ $data || {} } };
    form {
        while (my ($name, $field) = splice(@fields, 0, 2)) {
            input {
                attr {
                    type => "text",
                    name => $name,
                };
                my $val = $values->{$name};
                $val = $val->[0] if ref($val) eq 'ARRAY'; # FIXME!
                $val ||= "";
                return $val;
            };
        }
    }
};

1;
