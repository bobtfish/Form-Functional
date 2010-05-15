package Form::Functional::Reflector::FieldBuilder::Entry::MatchAttribute;
use Moose;
use Method::Signatures::Simple;
use Form::Functional::Reflector::Types qw/ Attribute /;
use namespace::autoclean;

method match ($item) {
    is_Attribute($item) && $item->has_init_arg;
}

with 'Form::Functional::Reflector::FieldBuilder::Entry::Role::MatchOnly';

__PACKAGE__->meta->make_immutable;
1;
