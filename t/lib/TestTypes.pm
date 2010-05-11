package TestTypes;
use MooseX::Types -declare => [qw/
    UCOnly
/];
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw/ Str /;

subtype UCOnly, as Str, where { uc($_) eq $_ };

1;
