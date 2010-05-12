use strict;
use warnings;
use Test::More;
use Form::Functional;
use aliased 'Form::Functional::Field';

{
    package Field::Compound::Date;

    use Moose::Role;
    use aliased 'Form::Functional::Field';
    use Method::Signatures::Simple;
    use namespace::autoclean;

    with 'Form::Functional::Field::Compound' => {
        fields => {
            lazy    => 1,
            builder => '_build_fields',
        },
    };

    has year_field => (
        is      => 'ro',
        builder => '_build_year_field',
    );

    has month_field => (
        is      => 'ro',
        builder => '_build_month_field',
    );

    has day_field => (
        is      => 'ro',
        builder => '_build_day_field',
    );

    method _build_fields {
        [map { ($_ => $self->${\"${_}_field"}) } qw(year month day)]
    }

    method _build_year_field {
        return Field->with_traits('Select')->new({
            coerce           => 0,
            required         => 1,
            type_constraints => [],
            valid_options    => [1920 .. 1900 + (localtime time)[5]],
        });
    }

    method _build_month_field {
        return Field->with_traits('Select')->new({
            coerce           => 0,
            required         => 1,
            type_constraints => [],
            valid_options    => [1 .. 12],
        });
    }

    method _build_day_field {
        return Field->with_traits('Select')->new({
            coerce           => 0,
            required         => 1,
            type_constraints => [],
            valid_options    => [1 .. 31],
        });
    }
}

my $form = Form::Functional->new({
    required         => 1,
    type_constraints => [],
    fields           => [
        date => Field->with_traits('+Field::Compound::Date')->new({
            coerce           => 0,
            required         => 1,
            type_constraints => [],
        }),
    ],
});

{
    my $res = $form->process({ date => { year => 1980, month => 4, day => 23 } });
    my %errors = $res->_errors;
    is scalar(%errors), 0, q{No errors, it's my birthday!}
        or diag explain { %errors };
}

{
    my $res = $form->process({ date => { year => 1986, month => 14, day => 13 } });
    my %errors = $res->_errors;
    ok exists($errors{date}), 'Date field has an error';
    is ref($errors{date}), 'ARRAY', 'Error data is an array';
}

# TODO - Test coercions
# 11:52 <t0m> coercions on the compound field itself fire before we pass the values into it?
# 11:52 <rafl> yeah, i think so. i'm just wondering where they should fire. both makes sense
# 11:52 <t0m> so that the higher level coercion gets to mangle the data before the individual sub-fields?
# 11:53 <rafl> yes, that's what happens currently, i think

done_testing;