package Form::Functional::Field;

use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw(Bool ArrayRef);
use MooseX::Types::LoadableClass qw(ClassName);
use MooseX::Types::Common::String qw(NonEmptySimpleStr);
use Form::Functional::Types qw(ConstraintList FieldCoercion IntersectionTypeConstraint RequiredMessage);
use aliased 'Moose::Meta::TypeCoercion';
use aliased 'MooseX::Meta::TypeConstraint::Intersection';
use namespace::autoclean;

with 'MooseX::Traits' => { -version => 0.09 };

has '+_trait_namespace' => (
    default => __PACKAGE__,
);

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
    builder   => '_build_coercion',
    predicate => 'has_coercion'
);

has error_class => (
    is      => 'ro',
    isa     => ClassName,
    coerce  => 1,
    default => 'Form::Functional::Error',
    handles => {
        _new_error => 'new',
    },
);

around BUILDARGS => sub {
    my ($orig, $self) = (shift, shift);
    my $args = $self->$orig(@_);
    return {
        %{ $args },
        (exists $args->{coercion} ? (coerce => 1) : ()),
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

method _build_required_message_cb {
    return sub {
        $self->_new_error({
            message   => "Field [_1] is required",
            arguments => [$_[1]],
        });
    };
}

method validate (@values) {
    my @msgs = map {
        $self->_new_error({
            message                => $_->[0],
            failed_type_constraint => $_->[1],
        })
    } map { @{ $_ } } grep defined, map {
        $self->type_constraint->validate_all($_)
    } @values;

    return unless @msgs;
    return \@msgs;
}

__PACKAGE__->meta->make_immutable;

1;
