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

=head1 DESCRIPTION

A set of Moose types used by Form::Functional

=head1 TYPES

=head2 CompoundField

Does the role L<Form::Functional::Field::Compound>.

=head2 Field

Is the class L<Form::Functional::Field> (or a subclass therof).

=head2 Fields

An array ref of pairs of C<Str>s and C<Field>s, containing no duplicate C<Str>s.

=head2 TypeConstraint

An instance of a class which isa L<Moose::Meta::TypeConstraint>.

=head2 TypeCoercion

A instance of a class which isa L<Moose::Meta::TypeCoercion>.

=head2 IntersectionTypeConstraint

An instance of a class which isa L<MooseX::Meta::TypeConstraint::Intersection>.

=head2 ConstraintList

An C<ArrayRef> of C<TypeConstraint>s. Coerces from C<TypeConstraint> by wrapping
the constraint in an array ref.

=head2 FieldCoercion

A C<CodeRef> which can be used to coerce the value for a field.

Coerces from a C<TypeCoercion> by extracting the coderef.

Coerces from a C<TypeConstraint> by extracting the associated C<TypeCoercion>
and extracting the associated C<CodeRef> from that.

=head2 RequiredMessage

A code ref which returns an array.

Coerces from C<ArrayRef> by wrapping the array ref in a closure.

Coerces from C<Str> by wrapping the string in an array ref and a closure.

Coerces from an C<ArrayRef> of C<TypeConstraint>s by extracting the associated
coercions and applying them in order.

FIXME - This is counter what we do (or advertise to do) for forms/fields,
where we refuse to build a coercsion when there is more than one coercion.

=head2 InputValues

=head2 Error

An instance of a class which isa L<Form::Functional::Error>

=head2 Errors

An arrayref containing C<Error> or C<Errors>.

=cut
