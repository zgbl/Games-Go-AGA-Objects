#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents an AGA Player
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;
use Games::Go::AGA::Objects::ID_Normalizer_Role;
use Games::Go::AGA::Objects::Types;

class Games::Go::AGA::Objects::Player
    does Games::Go::AGA::Objects::ID_Normalizer_Role {

=begin pod

=head1 SYNOPSIS

    use Games::Go::AGA::Objects::Player;

    my Games::Go::AGA::Objects::Player $player .= new( :id<TMP1>, ... );

=head1 DESCRIPTION

Games::Go::AGA::Objects::Player abstracts an AGA registered player.

=head1 ATTRIBUTES

Attributes may be retrieved with the name of the attribute (e.g:
$directive.key). Settable attributes are set with the name prefixed by
'set-' (e.g: $game.set-id( ... )).

=item id => Str [ required ]       # AGA or tmp ID
=item last-name => Str [ required ]
=item first-name => Str = ''
=item rank-or-rating => Rank-or-Rating [ required ]
=item membership-type => Str = ''
=item membership-date => Date
=item state => Str = ''
=item comment => Str = ''
=item sigma => Num                # for the calculating ratings
=item flags => Str = '' # other flags
=item change-flag => Bool = False   # set by changed()
=item change-callback => sub { }

Callback called from the B<changed> method.

=end pod

    has Str            $.id is required;       # AGA or tmp ID
    has AGA-Id         $!normalized-id;
    has Str            $.last-name is required;
    has Str            $.first-name      = '';
    has Rank-or-Rating $.rank-or-rating is required;
    has Str            $.membership-type = '';
    has Date           $.membership-date;
    has Str            $.state           = '';
    has Str            $.comment         = '';
    has Num            $.sigma;                # for the calculating ratings
    has Str            $.flags           = ''; # other flags
    has                &.change-callback = sub { };
    has Bool           $.change-flag     = False;   # set by changed()

=begin pod
=head1 METHODS

Methods that don't explicitly return a value return B<self> to enable
chaining.
=end pod

    method id { #= Returns normalized B<id>.
        $!normalized-id = $.normalize-id($!id) if $!normalized-id.not;
        $!normalized-id;
    }
    method id_original { #= Returns original (non-normalized) B<id>
        $!id;
    }

    ######################################
    #
    # accessors
    #
    method set-id (AGA-Id $i)            { $!id              = $i; $.changed; } #=
    method set-last-name (Str $l)        { $!last-name       = $l; $.changed; } #=
    method set-first-name (Str $f)       { $!first-name      = $f; $.changed; } #=
    method set-rank-or-rating (Rank-or-Rating $r) { $!rank-or-rating = $r; $.changed; } #=
    method set-membership-type (Str $t)  { $!membership-type = $t; $.changed; } #=
    method set-membership-date (Date $d) { $!membership-date = $d; $.changed; } #=
    method set-state (Str $s)            { $!state           = $s; $.changed; } #=
    method set-comment (Str $c)          { $!comment         = $c; $.changed; } #=
    method set-sigma (Rat $s)            { $!sigma           = $s; $.changed; } #=
    method set-flags (Str $f)            { $!flags           = $f; $.changed; } #=
    method set-change-callback (&ccb)    { &!change-callback = &ccb; self;    } #=

    ######################################
    #
    # methods
    #
    method set-changed-flag (Bool $new = True) { $!change-flag = $new; self; } #=
    #| Called to indicate a change (called from
    #| B<set-id>,
    #| B<set-last-name>,
    #| B<set-first-name>,
    #| B<set-rank-or-rating>,
    #| B<set-membership-type>,
    #| B<set-membership-date>,
    #| B<set-state>,
    #| B<set-comment>,
    #| B<set-sigma>,
    #| B<set-flags>.
    #| Calls B<change-callback>.
    method changed { &!change-callback(); $.set-changed-flag(); self; }

    #| Returns the B<rank-or-rating> in B<Rating> form (decimal number).
    method rating ( Rank-or-Rating $rating = $!rank-or-rating ) {
        given $rating {
            when Rating { $rating }
            default {   # convert Rank to Rating
                $rating ~~ m:i/(\d+)(<[dk]>)/;
                $/[1].uc ~~ 'D'
                ??  $/[0] + 0.5   # dan from 1 up
                !! -$/[0] - 0.5;  # kyu from -1 down
            }
        }
    }
    #| Returns the B<rank-or-rating> in B<Rank> form (e.g: '4D', '10K').
    method rank ( Rank-or-Rating $rank = $!rank-or-rating ) {
        given $rank {
            when Rank { $rank }
            default {   # convert Rating to Rank
                $rank.Int.abs ~ ($rank >= 0 ?? 'D' !! 'K');
            }
        }
    }

    ######################################
    #
    # other methods
    #
    #| Returns a single B<flag> value by its key.
    method flag (Str $key) {
        $!flags ~~ m:i/ << $key '=' (\S+) /;
        ~$0 if $0.defined;
    }
    #| Returns the 'Club' flag value (if any).
    method club { $.flag('Club') }      # required for TDList Club column

    #| Returns "B<last-name>, B<first-name>", or just "B<last-name>" if
    #| B<first-name> is not set.
    method full-name {
        $!first-name
          ?? "$!last-name, $!first-name"
          !! $!last-name;
    }
    #| Returns the Player information in a single line suitable for
    #| inclusion in a I<register.tde> file.
    method sprint {
        my $rOr = $.rank-or-rating;
        if $rOr ~~ Rat {
            $rOr = sprintf "%.1f", $rOr;   # want one decimal of accuracy, even if .0
        }
        (
            $.id,
            $!last-name ~ ($!first-name.so ?? ',' !! ''),
            $!first-name,
            $rOr,
            $!flags,
            $!comment,
        ).grep({ .so }).join(' ');
    }
}

=begin pod
=head1 SEE ALSO

=item L<Games::Go::AGA::Objects::Register>
=item L<Games::Go::AGA::Objects::Types>

=end pod

# vim: expandtab shiftwidth=4 ft=perl6
