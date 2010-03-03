package Form::Functional::Field;

use Moose::Role;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw(Bool ArrayRef);
use MooseX::Types::Common::String qw(NonEmptySimpleStr);
use Form::Functional::Types qw(ConstraintList FieldCoercion IntersectionTypeConstraint);
use aliased 'Moose::Meta::TypeCoercion';
use aliased 'MooseX::Meta::TypeConstraint::Intersection';
use namespace::autoclean;

has name => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
    required => 1,
);

has required => (
    isa      => Bool,
    required => 1,
    reader   => 'is_required',
);

has type_constraint => (
    is       => 'ro',
    isa      => IntersectionTypeConstraint,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_type_constraint',
);

has type_constraints => (
    traits   => [qw(Array)],
    isa      => ConstraintList,
    required => 1,
    provides => {
        type_constraints        => 'elements',
        _count_type_constraints => 'count',
        _first_type_constraint  => [ get => 0 ],
    },
);

has coerce => (
    isa      => Bool,
    required => 1,
    reader   => 'should_coerce',
);

has coercion => (
    is        => 'ro',
    isa       => FieldCoercion,
    lazy      => 1,
    builder   => '_build_coercion',
    predicate => 'has_coercion'
);

method BUILD {
    $self->_build_type_constraint;
}

method _build_type_constraint {
    my $tc = Intersection->new(
        type_constraints => [ $self->type_constraints ],
    );

    if ($self->should_coerce) {
        my $coercion = Coercion->new(
            type_constraint => $tc,
        );

        confess "Coercing a field with more than one type constraint requires an explicit coercion rule"
            if $self->_count_type_constraints > 0 && !$self->has_coercion;

        my $converter = $self->has_coercion
            ? $self->coercion
            : $self->_first_type_constraint->coercion->_compiled_type_coercion;

        $coercion->_compiled_type_coercion($converter);

        $tc->coercion($tc);
    }

    return $tc;
}

1;
