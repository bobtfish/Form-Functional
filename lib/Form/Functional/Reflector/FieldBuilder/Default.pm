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
use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::RequiredFromConstraint';
use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::NameFromConstraint';
use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::TypeConstraintFromConstraint';

method _build_entries { [
    MatchAttribute->chain( {},
        NameFromAttribute->chain( {},
            RequiredFromAttribute->chain( {},
                TypeConstraintFromAttribute->new
    ))),
    MatchTypeConstraint->chain( {},
        NameFromConstraint->chain( {},
            RequiredFromConstraint->chain( {},
                TypeConstraintFromConstraint->new
    ))),
] }

__PACKAGE__->meta->make_immutable;
1;
