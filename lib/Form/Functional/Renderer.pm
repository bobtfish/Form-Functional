package Form::Functional::Renderer::TD;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

method render ($form_or_processed) {
    my @fields = $form_or_processed->fields;
}

with 'Form::Functional::Renderer';

__PACKAGE__->meta->make_immutable;
