package Form::Functional::FieldBuilder;

use Moose;
use Moose::Meta::Class;
use Moose::Util qw(find_meta);
use Method::Signatures::Simple;
use MooseX::Types::Structured qw(Dict);
use MooseX::Types::Moose qw(HashRef ArrayRef Str);
use MooseX::Types::LoadableClass qw(LoadableClass LoadableRole);
use Moose::Util::TypeConstraints;
use String::RewritePrefix;
use Data::OptList;
use namespace::autoclean;

has field_class_prefix => (
    is => 'ro',
    isa => Str,
    default => 'Form::Functional::Field::C',
);

has field_base_class => (
    is => 'ro',
    isa => LoadableClass,
    coerce => 1,
    default => 'Form::Functional::Field',
);

has field_role_prefix => (
    is => 'ro',
    isa => Str,
    default => 'Form::Functional::Field',
);

method make ($class_or_self: $args) {
    defined $_ && confess $_ for (Dict[
        as   => ArrayRef[Str|HashRef],
        with => HashRef,
    ])->validate($args);

    my $self = blessed $class_or_self
        ? $class_or_self
        : $class_or_self->new;

    my $roles = Data::OptList::mkopt($args->{as});

    foreach my $role (@$roles) {
        $role->[0] = to_LoadableRole( String::RewritePrefix->rewrite(
            { '' => $self->field_role_prefix . q{::}, '+' => '' },
            $role->[0]
        ));
    }
    # FIXME - This is not unique - Roles Foo and Bar vs Role Foo_Bar
    my $name = join q{::} => $self->field_class_prefix, join q{_} => sort map { $_->[0] } @$roles;

    my $meta = Class::MOP::is_class_loaded($name)
        ? find_meta($name)
        : Moose::Meta::Class->create(
        $name,
        superclasses => [$self->field_base_class],
        roles        => [ grep { defined $_ } map { @$_ } @$roles ],
    );

    return $meta->name->new($args->{with});
}

__PACKAGE__->meta->make_immutable;

1;
