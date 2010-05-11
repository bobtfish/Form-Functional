package Form::Functional::Types;

use MooseX::Types::Moose qw(Str ArrayRef HashRef CodeRef);
use MooseX::Types -declare => [qw(
    Form
    Field
    TypeConstraint
    IntersectionTypeConstraint
    ConstraintList
    FieldCoercion
    RequiredMessage
    InputValues
)];

class_type Form, { class => 'Form::Functional' };
class_type TypeConstraint, { class => 'Moose::Meta::TypeConstraint' };
class_type IntersectionTypeConstraint, { class => 'MooseX::Meta::TypeConstraint::Intersection' };

class_type Field, { class => 'Form::Functional::Field' };

subtype ConstraintList, as ArrayRef[TypeConstraint];
coerce ConstraintList, from TypeConstraint, via { [$_] };

subtype FieldCoercion, as CodeRef;
coerce FieldCoercion, from TypeConstraint, via {
    $_->coercion->_compiled_type_coercion
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

__PACKAGE__->meta->make_immutable;

1;
