use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;

use Form::Functional::Reflector::FieldBuilder;
use aliased 'MockFieldBuilderEntry' => 'Entry';

{
    my $fb = Form::Functional::Reflector::FieldBuilder->new;
    ok $fb;
}

done_testing;
