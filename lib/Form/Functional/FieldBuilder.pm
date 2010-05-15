package Form::Functional::FieldBuilder;

use Moose;
use Moose::Meta::Class;
use Moose::Util qw(find_meta);
use Method::Signatures::Simple;
use MooseX::Types::Structured qw(Dict);
use MooseX::Types::Moose qw(HashRef ArrayRef Str);
use MooseX::Types::LoadableClass qw(LoadableClass LoadableRole);
use String::RewritePrefix;
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
        as   => ArrayRef[Str],
        with => HashRef,
    ])->validate($args);

    my $self = blessed $class_or_self
        ? $class_or_self
        : $class_or_self->new;

    my @roles = String::RewritePrefix->rewrite(
            { '' => $self->field_role_prefix . q{::}, '+' => '' },
            @{ $args->{as} }
    );
    my $name = join q{::} => $self->field_class_prefix, join q{_} => sort @roles;

    my $meta = Class::MOP::is_class_loaded($name)
        ? find_meta($name)
        : Moose::Meta::Class->create(
        $name,
        superclasses => [$self->field_base_class],
        roles        => [
            map { to_LoadableRole( $_ ) } @roles
        ],
    );

    return $meta->name->new($args->{with});
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

=attr field_class_prefix

=attr field_role_prefix

=attr field_base_class

=method make

=cut
