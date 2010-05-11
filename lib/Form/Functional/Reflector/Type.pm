package Form::Functional::Reflector::Type;
use Moose;
use Method::Signatures::Simple;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

method generate_form_from ($type_or_name) {
    my $tc = blessed($type_or_name) ? $type_or_name : find_type_constraint($type_or_name);
    confess "Could not find type constraint named $type_or_name, is is defined?"
        unless $tc;



    $self->form_class->new(
             fields => { },
    );
}

with 'Form::Functional::Reflector';

__PACKAGE__->meta->make_immutable;
