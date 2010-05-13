package Form::Functional::Reflector::FieldBuilder::Default;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

extends 'Form::Functional::Reflector::FieldBuilder';

use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::MatchAttribute';
use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::RequiredFromAttribute';
use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::NameFromAttribute';
use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::TypeConstraintFromAttribute';

use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::MatchTypeConstraint';

method _build_entries { [
    MatchAttribute->new->chain(
        NameFromAttribute->new->chain(
            RequiredFromAttribute->new->chain(
                TypeConstraintFromAttribute->new
    ))),
    MatchTypeConstraint->new,
] }

__PACKAGE__->meta->make_immutable;
1;
