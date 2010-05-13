package Form::Functional::Types;
# ABSTRACT: Type definitions for Form::Functional

use List::AllUtils qw(natatime);
use MooseX::Types::Moose qw(Str ArrayRef HashRef CodeRef);
use MooseX::Types::Structured qw(Map);
use MooseX::Types -declare => [qw(
    CompoundField
    Field
    Fields
    TypeConstraint
    TypeCoercion
    IntersectionTypeConstraint
    ConstraintList
    FieldCoercion
    RequiredMessage
    InputValues
    Error
    Errors
)];
use namespace::clean -except => [qw/ meta /];

role_type CompoundField, { role => 'Form::Functional::Field::Compound' };
class_type TypeConstraint, { class => 'Moose::Meta::TypeConstraint' };
class_type TypeCoercion, { class => 'Moose::Meta::TypeCoercion' };
class_type IntersectionTypeConstraint, { class => 'MooseX::Meta::TypeConstraint::Intersection' };

class_type Field, { class => 'Form::Functional::Field' };

subtype ConstraintList, as ArrayRef[TypeConstraint];
coerce ConstraintList, from TypeConstraint, via { [$_] };

subtype FieldCoercion, as CodeRef;
coerce FieldCoercion, from TypeConstraint, via {
    $_->coercion->_compiled_type_coercion
};
coerce FieldCoercion, from TypeCoercion, via {
    $_->_compiled_type_coercion
};
coerce FieldCoercion, from ArrayRef[TypeConstraint], via {
    my @coercions = map { $_->coercion->_compiled_type_coercion } @{ $_ };
    return sub {
        my $value = $_;
        for my $coercion (@coercions) {
            local $_ = $value;
            $value = $coercion->();
        }
    };
};

subtype RequiredMessage, as CodeRef;
coerce RequiredMessage, from Str, via { my $msg = $_; sub { [$msg] } };
coerce RequiredMessage, from ArrayRef, via { my $msg = $_; sub { $msg } };

subtype InputValues, as HashRef[ArrayRef];
coerce InputValues, from HashRef, via {
    my $v = $_;
    +{ map { ($_ => [$v->{$_}]) } keys %{ $v } }
};

my $map = Map[Str, Field];
subtype Fields, as ArrayRef, where {
    my @l = @{ $_ };
    my $it = natatime 2, @l;
    my %seen;
    while (my ($k) = $it->()) {
        return 0 if $seen{$k}++;
    }
    $map->check({ @l })
};

class_type Error, { class => 'Form::Functional::Error' };
subtype Errors, as HashRef[ArrayRef[Error|Errors]];

__PACKAGE__->meta->make_immutable;

1;
