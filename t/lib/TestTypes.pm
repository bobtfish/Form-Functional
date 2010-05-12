package TestTypes;
use MooseX::Types -declare => [qw/
    UCOnly
    UCOnlyTwo
    UCOnlyNoCoercion
/];
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw/ Str /;

subtype UCOnly, as Str, where { uc($_) eq $_ };
coerce UCOnly, from Str, via { uc($_) };

subtype UCOnlyTwo, as Str, where { uc($_) eq $_ };
coerce UCOnlyTwo, from Str, via { uc($_) };

subtype UCOnlyNoCoercion, as Str, where { uc($_) eq $_ };

1;
