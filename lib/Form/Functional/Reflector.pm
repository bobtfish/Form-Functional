package Form::Functional::Reflector;
use Moose::Role;
use MooseX::Method::Signatures;
use MooseX::Types::LoadableClass qw/ClassName/;
use Form::Functional::Reflector::Types qw/ FieldBuilder TypeMap /;
use namespace::autoclean;

use aliased 'Form::Functional::Reflector::FieldBuilder::Default' => 'DefaultFieldBuilder';

requires qw/
    generate_form_from
/;

has form_class => (
    isa => ClassName,
    is => 'ro',
    coerce => 1,
    default => 'Form::Functional',
);

has field_builder_class => (
    isa => FieldBuilder,
    is => 'ro',
    required => 1,
    default => sub { DefaultFieldBuilder->new },
);

method _build_form_from_fields (@fields) {
    $self->form_class->new(
        fields => \@fields,
        required         => 1,
        type_constraints => [],
    );
}

1;
