package Form::Functional::Reflector::MetaClass;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw/ Any /;
use Moose::Util qw/ find_meta /;
use aliased 'Form::Functional::Field';
use namespace::autoclean;

method generate_form_from ($class_or_meta) {
    my $meta = blessed($class_or_meta)
        ? $class_or_meta
        : do {
            confess "Could not find $class_or_meta, is is loaded?"
                unless Class::MOP::is_class_loaded($class_or_meta);
            find_meta $class_or_meta
        };
    confess "Could not find metaclass for $class_or_meta, is is loaded?"
        unless $meta;
    confess $meta->name . " does not have a Moose metaclass, cannot reflect" # Fuck you if you can find_meta
        unless $meta->isa('Moose::Meta::Class');                             # but have no ->name

    my @fields;

    # FIXME - Ordering
    foreach my $attr ($meta->get_all_attributes) {
        next unless $attr->has_init_arg;
        my $name = $attr->init_arg;
        my $optional = ($attr->has_builder || $attr->has_default || !$attr->is_required) ? 1 : 0;
        my $tc = $attr->has_type_constraint ? $attr->type_constraint : Any;
        push(@fields,
            $name => Field->new(
                coerce => $tc->has_coercion,
                required => !$optional,
                type_constraints => [ $tc ],
            )
        );
    }

    $self->_build_form_from_fields(@fields);
}

with 'Form::Functional::Reflector';

__PACKAGE__->meta->make_immutable;
