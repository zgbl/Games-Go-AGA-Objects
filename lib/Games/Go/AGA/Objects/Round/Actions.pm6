#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Actions for Games::Go::AGA::Objects::Round
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  Sun Apr 17 11:35:25 PDT 2016
#===============================================================================
use v6;

class Games::Go::AGA::Objects::Round::Actions {
    use Games::Go::AGA::Objects::Types;
    use Games::Go::AGA::Objects::Round;

    ######################################
    #
    # 'action object' methods - construct G::G::A::O::Round directly
    #   from the Grammar:
    #
    method TOP ($/) {
       make Games::Go::AGA::Objects::Round.new(
            round-number => 0,
            comments     => $<line-comment>>>.ast,
            games        => $<game>>>.ast,
        );
    }
    method game ($/) {
        make Games::Go::AGA::Objects::Game.new(
            white-id => ~$<white-id>,
            black-id => ~$<black-id>,
            result   => ~$<result>,
            handicap => +$<handicap>,
            komi     => +$<komi>,
            comment  => ~$<game-comment>,
        );
    }

    method line-comment ($/) {
        make $/.Str.trim;   # simple string, trim leading and trailing whitespace
    }
}

=begin pod
=head1 SYNOPSIS

    use Games::Go::AGA::Objects::Round::Actions;

    my $content = slurp '1.tde';    # round files are 1.tde, 2.tde, etc
    my Games::Go::AGA::Objects::Round::Actions $actions .= new();
    my $register = Games::Go::AGA::Objects::Round::Grammar.parse($content, :actions($actions)).ast;

=header1 DESCRIPTION

Use Games::Go::AGA::Objects::Round::Actions with the associated
Games::Go::AGA::Objects::Round::Grammar to create a
Games::Go::AGA::Objects::Round object directly from a file or string.

=head1 SEE ALSO

=item L<Games::Go::AGA::Objects::Round>

=end pod


# vim: expandtab shiftwidth=4 ft=perl6
