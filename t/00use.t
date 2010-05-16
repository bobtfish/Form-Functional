use strict;
use warnings;
use Test::More 0.88;

use Module::Pluggable search_path => ['Form::Functional'];

use_ok($_) for __PACKAGE__->plugins;

done_testing;
