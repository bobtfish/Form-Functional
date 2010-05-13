package Form::Functional::Reflector::FieldBuilder::Entry;
use Moose::Role;
use Form::Functional::Reflector::Types qw/FieldBuilderEntry/;
use namespace::autoclean;

requires qw(match apply);

use aliased 'Form::Functional::Reflector::FieldBuilder::Entry::MatchNever';

# FIXME - This is a massive chunk of fail, as it basically means that you
#         can't subclass entry classes and override apply, which is clearly
#         something you want to do. E.g. XXXXFromAttribute should just subclass
#         MatchAttribute
around apply => sub {
    my ($orig, $self, $result, $item) = @_;
    my $new_result = $self->$orig($result, $item);
    $new_result ||= $result; # We still chain in this case, sane?
    if ($self->next_link_matches($item)) {
        my $chained_new_result = $self->apply_to_next_link($new_result, $item);
        $new_result = $chained_new_result if $chained_new_result;
    }
    return $new_result;
};

# FIXME - Mutability, stab, kill destroy.
has next_link => (
    isa => FieldBuilderEntry,
    is => 'ro',
    writer => 'chain',
    default => sub { MatchNever->new },
    handles => {
        apply_to_next_link => 'apply',
        next_link_matches => 'match',
    }
);

around chain => sub {
    my ($orig, $self, @vals) = @_;
    $self->$orig(@vals);
    return $self;
};

1;
