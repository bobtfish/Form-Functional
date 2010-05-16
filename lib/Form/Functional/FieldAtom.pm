package Form::Functional::FieldAtom;

use Moose::Role;
use Method::Signatures::Simple;
use List::AllUtils qw(any);
use MooseX::Types::Moose qw(Bool ArrayRef);
use MooseX::Types::LoadableClass 0.004 qw(LoadableClass LoadableRole);
use MooseX::Types::Common::String qw(NonEmptySimpleStr);
use Form::Functional::Types qw(ConstraintList FieldCoercion IntersectionTypeConstraint RequiredMessage);
use aliased 'Moose::Meta::TypeCoercion';
use aliased 'MooseX::Meta::TypeConstraint::Intersection';
use namespace::autoclean;

with 'MooseX::Clone';

=method clone

From L<MooseX::Clone>, allows the trivial cloning of fields (whilst overriding
some) attributes.

=attr required

Boolean representing if a value must be supplied for this field

Note that the reader for this attribute is named L</is_required>.

=method is_required

A predicate method returning the values of the L</required> atttribute.
Signifies if this field is required for the containing form (or compound field)
to validate.

=cut

has required => (
    isa      => Bool,
    required => 1,
    reader   => 'is_required',
);

has required_message_cb => (
    traits   => [qw(Code)],
    is       => 'ro',
    isa      => RequiredMessage,
    coerce   => 1,
    init_arg => 'required_message',
    lazy     => 1,
    builder  => '_build_required_message_cb',
    handles  => {
        required_message => 'execute_method',
    },
);

=attr type_constraint

The intersection of all type constraints for this field (i.e. to fulfil this)
type constraint, all type constraints must pass.

=cut

has type_constraint => (
    is       => 'ro',
    isa      => IntersectionTypeConstraint,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_type_constraint',
);

=attr type_constraints

A list of type constraints associcated with this field.

=cut

has type_constraints => (
    traits   => [qw(Array)],
    isa      => ConstraintList,
    required => 1,
    handles  => {
        type_constraints        => 'elements',
        _count_type_constraints => 'count',
        _first_type_constraint  => [ get => 0 ],
    },
);

=attr coerce

A boolean representing if the type constraint(s) for this field will try to
coerce the user supplied value(s) before checking.

If an explicit coercion is supplied, then coercion will be automatically
enabled.

=cut

has coerce => (
    isa     => Bool,
    default => 0,
    reader  => 'should_coerce',
);

=attr coercion

THe coercion for this field.

If there is only one type constraint for this field then the coercion on that type
constraint (if present) will automatically be used. Alternatively (and in cases where
the field has more than one type constraint), the coercion can be supplied.

=cut

has coercion => (
    is        => 'ro',
    isa       => FieldCoercion,
    lazy      => 1,
    coerce    => 1,
    builder   => '_build_coercion',
    predicate => 'has_coercion'
);

=attr error_class

The class which should be used to report validation errors for this field.

This class should duck type L<Form::Functional::Error>, as it will be constructed
with the attribues for that class, but it is not required to inherit from it.

=cut

has error_class => (
    is      => 'ro',
    isa     => LoadableClass,
    coerce  => 1,
    default => 'Form::Functional::Error',
    handles => {
        _new_error => 'new',
    },
);

has _with_init_value_trait => (
    is       => 'ro',
    isa      => LoadableRole,
    coerce   => 1,
    init_arg => undef, # Maybe[FIXME]
    builder  => '_build__with_init_value_trait',
);

requires '_build__with_init_value_trait';

around _with_init_value_trait => sub {
    my ($orig, $self) = @_;
    return $self->$orig->meta;
};

around BUILDARGS => sub {
    my ($orig, $self) = (shift, shift);
    my $args = $self->$orig(@_);
    return {
        %{ $args },
        (exists $args->{coercion}
             ? (coerce => 1)
             : ()),
    };
};

method BUILD {}

after BUILD => sub {
    my ($self) = shift;
    $self->_build_type_constraint;
};

method _build_type_constraint {
    my $tc = Intersection->new(
        type_constraints => [ $self->type_constraints ],
    );

    if ($self->should_coerce) {
        my $coercion = TypeCoercion->new(
            type_constraint => $tc,
        );

        my $converter;
        if ($self->has_coercion) {
            $converter = $self->coercion;
        }
        else {
            confess "Coercing a field with more than one type constraint requires an explicit coercion rule"
                if $self->_count_type_constraints > 1;

            my $tc = $self->_first_type_constraint;
            confess "Cannot coerce a field with a type constraint ($tc) which has no coercion defined"
                unless $tc->has_coercion;

            $converter = $tc->coercion->_compiled_type_coercion;
        }

        $coercion->_compiled_type_coercion($converter);

        $tc->coercion($coercion);
    }

    return $tc;
}

method _build_required_message_cb {
    return sub {
        $self->_new_error({
            message   => "Field [_1] is required",
            arguments => [$_[1]],
        });
    };
}

1;

=head1 DESCRIPTION

This role encapsulates all the common functionality for form fields.

=cut

