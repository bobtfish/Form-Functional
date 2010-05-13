package Form::Functional::Reflector::Types;
# ABSTRACT: Type definitions for the Form::Functional Reflector

use MooseX::Types -declare => [qw(
    TypeMap
    TypeMapEntry
    FieldBuilder
    FieldBuilderEntry
    Attribute
)];
use namespace::clean -except => [qw/ meta /];

class_type TypeMap,      { class => 'Form::Functional::Reflector::TypeMap'        };
class_type TypeMapEntry, { class => 'Form::Functional::Reflector::TypeMap::Entry' };

class_type FieldBuilder,      { class => 'Form::Functional::Reflector::FieldBuilder'        };
role_type  FieldBuilderEntry, { role  => 'Form::Functional::Reflector::FieldBuilder::Entry' };

class_type Attribute, { class => 'Moose::Meta::Attribute' };

__PACKAGE__->meta->make_immutable;
1;
