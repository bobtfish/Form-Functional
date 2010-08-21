package Form::Functional::Field::WithRenderData;
use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw/ HashRef /;
use Form::Functional::Types qw/ TypeConstraint /;
use namespace::autoclean;

# <rafl> i believe WithRenderData should be more structured
# <rafl> has [qw(label id ...)]
# <rafl> (also, trying to build the label automatically as ucfirst $field_name, or something, will probably be a good test on how right things are right now)
# <rafl> hrm.. other thought.
# <t0m> I'm all down with more structured, but that means we're going to have different render data for the top level form and individual fields.
# <rafl> role WithRenderingMetadata { has ArrayRef rendering_metadata  }
# <t0m> And yep, automatic labels would be good.
# <rafl> rendering_data => [qw(action method legend)]
# <rafl> role RenderingMetadata::Form { has [qw(action method legend)] }
# <rafl> role RenderingMetadata::Discrete { has [qw(label)] }
# <rafl> role RenderingMetadata::Field { has [qw(name id)] }
# <rafl> etc
# <rafl> reasonable?
# <t0m> yep
# <rafl> with the first thing basically just saying what else is there, so huge ->does cascades can be avoided. helper method on exists rendering_metadata->{$thing} or whatever

parameter type_constraint => (
    isa => TypeConstraint, # FIXME - Validate is a sub type of HashRef
    is => 'ro',
    default => sub { HashRef() },
);

role {
    my $p = shift;
    my $tc = $p->type_constraint;

    has render_data => (
        is => 'ro',
        isa => $tc,
        default => sub { {} },
    );
};

1;
