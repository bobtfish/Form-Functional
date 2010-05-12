package Form::Functional::Reflector;
use Moose::Role;
use MooseX::Method::Signatures;
use MooseX::Types::LoadableClass qw/ClassName/;
use namespace::autoclean;

requires qw/
    generate_form_from
/;

has form_class => (
    isa => ClassName,
    is => 'ro',
    coerce => 1,
    default => 'Form::Functional',
);

method _build_form_from_fields (@fields) {
    $self->form_class->new(
        fields => \@fields,
        required         => 1,
        type_constraints => [],
    );
}

1;
