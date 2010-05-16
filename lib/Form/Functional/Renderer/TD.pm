package Form::Functional::Renderer::TD;
use Moose;
use Method::Signatures::Simple;
use Template::Declare;
use MooseX::Types::LoadableClass qw(LoadableClass);
use namespace::autoclean;

has template_class => (
    isa     => LoadableClass,
    is      => 'ro',
    coerce  => 1,
    default => 'Form::Functional::Renderer::TD::Templates',
);

method BUILD {
    Template::Declare->init( dispatch_to => [ $self->template_class ] );
}

method render ($thingy) {
    return $self->render_form($thingy)
        if $thingy->does('Form::Functional::Field::Compound');
    return $self->render_processed($thingy);
}

method render_form ($form) {
    return Template::Declare->show(form => $form)
}

method render_processed ($processed) {
    return Template::Declare->show(processed_form => $processed);
}

with 'Form::Functional::Renderer';

__PACKAGE__->meta->make_immutable;
