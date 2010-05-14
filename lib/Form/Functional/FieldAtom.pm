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
    handles  => {
        type_constraints        => 'elements',
        _count_type_constraints => 'count',
        _first_type_constraint  => [ get => 0 ],
    },
);

has coerce => (
    isa     => Bool,
    default => 0,
    reader  => 'should_coerce',
);

has coercion => (
    is        => 'ro',
    isa       => FieldCoercion,
    lazy      => 1,
    coerce    => 1,
    builder   => '_build_coercion',
    predicate => 'has_coercion'
);

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

method BUILD {
    $self->_build_type_constraint;
}

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
