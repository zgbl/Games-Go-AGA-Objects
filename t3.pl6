
my class a {
    has @.b;
    method get { @!b.map(|*.get); }
    method p {
        say 'A: ', $.get.perl;
        # why doesn't this loop act like C: below?
        for $.get() -> $c {
            say 'B: ', $c.perl
        }
    }
}
my class b {
    has @.c;
    method get { @!c };
}

my $a = a.new(
    b => (
        b.new( c => (1, 2, 3) ),
        b.new( c => (5, 6, 7) ),
    )
);

$a.p();

for $a.get() -> $c {
    say 'C: ', $c.perl
}


# vim: expandtab shiftwidth=4 ft=perl6
