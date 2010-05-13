package Form::Functional::Reflector::MetaClass;
use Moose;
use Method::Signatures::Simple;
use Moose::Util qw/ find_meta /;
use namespace::autoclean;

method get_fields_from_reflectee ($meta) {
    $meta->get_all_attributes;
}

method validate_reflectee ($class_or_meta){
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
        unless $meta->isa('Moose::Meta::Class');                             # but have no ->name method
    return $meta;
}

with 'Form::Functional::Reflector';

__PACKAGE__->meta->make_immutable;
1;
