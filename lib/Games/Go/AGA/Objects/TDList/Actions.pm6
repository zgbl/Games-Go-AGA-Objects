#!/usr/bin/env perl6
#===============================================================================
#     ABSTRACT:  perl 6 Actions for Games::Go::AGA::Objects::TDList
#
#       AUTHOR:  Reid Augustin
#        EMAIL:  reid@hellosix.com
#      CREATED:  Wed Apr 20 12:36:10 PDT 2016
#===============================================================================
use v6;
use Games::Go::AGA::Objects::Types;
use Games::Go::AGA::Objects::Player;

class Games::Go::AGA::Objects::TDList::Actions {

    ######################################
    #
    # 'action object' methods - construct G::G::A::O::Players directly
    #   from the TDList Grammar:
    #
    method TOP ($/) {
        my $m = $<player>;  # the match
        my %opts;
        for <id last-name first-name membership-type state> -> $key {
            with $m{$key} { %opts{$key} = ~$m{$key} }
        }
        # options that need special treatment:
        with $m<club>            { %opts<flags> = "Club=" ~ $m<club> }
        with $m<membership-date> {
            my @mdy = $m<membership-date>.split(/\D+/);  # split on non-numerics
            %opts<membership-date> = Date.new(+@mdy[2], +@mdy[0], +@mdy[1]);
        }
        %opts<rank-or-rating> = ~$m<rank-or-rating> ~~ Rank  # string in Rank form?
            ?? ~$m<rank-or-rating>          # use Rank form
            !! $m<rank-or-rating>.Rat;      # numeric Rating form
        make Games::Go::AGA::Objects::Player.new(|%opts);
    }
}

=begin pod
=head1 SYNOPSIS

    use Games::Go::AGA::Objects::TDList:Actions;

    my $content = slurp 'TDListN.txt';    # membership list from AGA
    my Games::Go::AGA::Objects::TDList:Actions $actions .= new();
    my $register = Games::Go::AGA::Objects::TDList:Grammar.parse($content, :actions($actions)).ast;

=header1 DESCRIPTION

Use Games::Go::AGA::Objects::TDList:Actions with the associated
Games::Go::AGA::Objects::TDList:Grammar to create a
Games::Go::AGA::Objects::TDListDB object directly from a file or string.

=head1 SEE ALSO

=item L<Games::Go::AGA::Objects::TDListDB>

=end pod

# vim: expandtab shiftwidth=4 ft=perl6
