package Form::Functional::Reflector::Types;
# ABSTRACT: Type definitions for the Form::Functional Reflector

use MooseX::Types -declare => [qw(
    TypeMap
    TypeMapEntry
    FieldBuilder
    FieldBuilderEntry
    Attribute
    NameAndConstraintPair
)];
use MooseX::Types::Moose qw/ ArrayRef Str /;
use Form::Functional::Types qw/ TypeConstraint/;

use namespace::clean -except => [qw/ meta /];

class_type TypeMap,      { class => 'Form::Functional::Reflector::TypeMap'        };
class_type TypeMapEntry, { class => 'Form::Functional::Reflector::TypeMap::Entry' };

class_type FieldBuilder,      { class => 'Form::Functional::Reflector::FieldBuilder'        };
role_type  FieldBuilderEntry, { role  => 'Form::Functional::Reflector::FieldBuilder::Entry' };

class_type Attribute, { class => 'Moose::Meta::Attribute' };

subtype NameAndConstraintPair, as ArrayRef,
    where { is_ArrayRef($_) && scalar(@$_) == 2 && is_Str($_->[0]) && is_TypeConstraint($_->[1]) };

__PACKAGE__->meta->make_immutable;
1;
