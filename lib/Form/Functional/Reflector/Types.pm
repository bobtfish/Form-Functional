package Form::Functional::Reflector::Types;
# ABSTRACT: Type definitions for the Form::Functional Reflector

use MooseX::Types -declare => [qw(
    TypeMap
    TypeMapEntry
    FieldBuilderEntry
    Attribute
    NameAndConstraintPair
    FieldOutputter
    FieldComposer
)];
use MooseX::Types::Moose qw/ ArrayRef Str /;
use Form::Functional::Types qw/ TypeConstraint/;

use namespace::clean -except => [qw/ meta /];

class_type TypeMap,      { class => 'Form::Functional::Reflector::TypeMap'        };
class_type TypeMapEntry, { class => 'Form::Functional::Reflector::TypeMap::Entry' };

role_type  FieldBuilderEntry, { role  => 'Form::Functional::Reflector::FieldBuilder::Entry' };

class_type Attribute, { class => 'Moose::Meta::Attribute' };

subtype NameAndConstraintPair, as ArrayRef,
    where { is_ArrayRef($_) && scalar(@$_) == 2 && is_Str($_->[0]) && is_TypeConstraint($_->[1]) };

role_type FieldComposer, { role => 'Form::Functional::Reflector::FieldComposer' };
role_type FieldOutputter, { role => 'Form::Functional::Reflector::FieldOutputter' };

__PACKAGE__->meta->make_immutable;
1;
