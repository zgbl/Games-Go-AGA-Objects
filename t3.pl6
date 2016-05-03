
my class a {
    has @.b;
    method get-flat { @!b.map(|*.get-flat); }
    method p {
        say 'A: ', $.get-flat.perl;
        # why doesn't this loop act like D: below?
        for @.get-flat() -> $c {
            say 'B: ', $c.perl
        }
    }
}
my class b {
    has @.c;
    method get-flat { @!c };
}

my $a = a.new(
    :b(
        b.new( :c(1, 2) ),
        b.new( :c(5, 6) ),
    )
);

$a.p();
say '';

say 'C: ', $a.get-flat.perl;
for $a.get-flat() -> $c {
    say 'D: ', $c.perl
}


# vim: expandtab shiftwidth=4 ft=perl6
