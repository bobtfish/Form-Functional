package Form::Functional::Renderer::TD;
use Moose;
use Method::Signatures::Simple;
use Template::Declare;
use MooseX::Types::LoadableClass qw/ ClassName /;
use namespace::autoclean;

method render ($form_or_processed) {
    my @fields = $form_or_processed->fields;
    Template::Declare->init( dispatch_to => [ $self->temlate_class ] );
    Template::Declare->show( 'form' );
}

has template_class => (
    isa => ClassName,
    is => 'ro',
    coerce => 1,
    default => 'Form::Functional::Renderer::TD::Templates',
);

with 'Form::Functional::Renderer';

__PACKAGE__->meta->make_immutable;
