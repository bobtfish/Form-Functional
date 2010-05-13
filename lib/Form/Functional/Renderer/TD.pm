package Form::Functional::Renderer::TD;
use Moose;
use Method::Signatures::Simple;
use Template::Declare;
use MooseX::Types::LoadableClass qw/ ClassName /;
use namespace::autoclean;

method render ($form, $data) {
    Template::Declare->init( dispatch_to => [ $self->template_class ] );
    my $values = $form->isa('Form::Functional::Processed')
        ? { $form->values }
        : {}; # init values
    return Template::Declare->show(form => $form, $values);
}

has template_class => (
    isa => ClassName,
    is => 'ro',
    coerce => 1,
    default => 'Form::Functional::Renderer::TD::Templates',
);

with 'Form::Functional::Renderer';

__PACKAGE__->meta->make_immutable;
