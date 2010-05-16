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

=attr field_base_class

The base class which field roles are composed onto.

Defaults to the entirely empty L<Form::Functional::Field> class.

=cut

has field_base_class => (
    is => 'ro',
    isa => LoadableClass,
    coerce => 1,
    default => 'Form::Functional::Field',
);

# FIXME - These next two attributes actually don't in any way mean the same thing
#         however they are named so similarly that people are bound to confuse them
#         should we do something else for the prefixes for making the conjoined class
#         name?

has field_class_prefix => (
    is => 'ro',
    isa => Str,
    default => 'Form::Functional::Field::C',
);

has field_role_prefix => (
    is => 'ro',
    isa => Str,
    default => 'Form::Functional::Field',
);

=method make

Generates a new field according to the supplied specification.

Takes a hash reference of arguments. Valid keys in this hash reference are:

=head3 as

A list of role names (optionally followed by hashrefs of parameters to be passed
to the role) to compose onto the L</field_base_class>.

=head3 with

A hashref of arguments to be passed to the constructor of the generated
class.

=cut

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

=head1 SYNOPSIS

    use Form::Functional::FieldBuilder;
    my $builder = Form::Functional::FieldBuilder->new;
    my $form = $builder->make({
        as => ['Compound'],
        with => {
            fields => [
                a_field => $builder->make({
                    as   => ['Select'],
                    with => {
                        valid_options => [qw/ foo bar baz /],
                    },
                }),
                another_field => FieldBuilder->make({
                    as   => ['Discrete'],
                    with => {
                        coerce => 0,
                        required => 0,
                        type_constraints => [ Str ],
                    },
                }),
            ],
            required         => 1,
            type_constraints => [],
        },
    });

=head1 DESCRIPTION

The field builder is the low level interface for constructing fields for forms
in Form::Functional.

=cut
