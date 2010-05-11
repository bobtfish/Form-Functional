package Form::Functional::Renderer::TD::Templates;
use strict;
use warnings;
use Method::Signatures::Simple;
use Template::Declare::Tags;
use namespace::clean -except => [qw/ meta /];

use base 'Template::Declare';

template form => sub {
        form {
            p { 'Hello, world wide web!' }
        }
    }
};

1;
