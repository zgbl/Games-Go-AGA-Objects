#!/usr/bin/env perl6
################################################################################
# ABSTRACT:  Represents AGA register.tde file, Constructable from Grammar.
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@hellosix.com
#  CREATED:  04/07/2016 12:40:28 PM
################################################################################
use v6;

use Games::Go::AGA::Objects::Types;
use Games::Go::AGA::Objects::Directive;
use Games::Go::AGA::Objects::Player;

class Games::Go::AGA::Objects::Register {

=begin pod
=head1 SYNOPSIS

    use Games::Go::AGA::Objects::Register;

    my Games::Go::AGA::Objects::Register $register .= new( [ ... ] );

=header1 DESCRIPTION

Games::Go::AGA::Objects::Game represents a single game.

=head1 ATTRIBUTES

Attributes may be retrieved with the name of the attribute (e.g:
$directive.key). Settable attributes are set with the name prefixed by
'set-' (e.g: $game.set-white-id( ... )).

=item %!directives => Games::Go::AGA::Objects::Directive    # hash by key.tclc
=item %!players => Games::Go::AGA::Objects::Player          # hash by id
=item @!comments => Str                                     # array of strings
=item change-callback => sub { };

Callback called from the B<changed> method.  You might want to set
this after populating the Register.

=end pod

    has Games::Go::AGA::Objects::Directive %!directives;   # hash by key.tclc
    has Games::Go::AGA::Objects::Player    %!players;      # hash by player.id
    has Str                                @.comments;     # array of strings
    has                                    &.change-callback;

    submethod BUILD (:&change-callback,
                     :@comments,
                     :@directives,
                     :@players) {
        &!change-callback = &change-callback // sub {};       # first!
        @comments.map( { self!_add-comment($_) } );
        @directives.map( { self!_set-directive($_) } );
        @players.map( { self!_add-player($_) } );
    };

    #| Set B<change-callback>.
    method set-change-callback ($ccb) { &!change-callback = $ccb; self; };
    #| Called to indicate a change (called from
    #| B<set-comment>,
    #| B<delete-comment>,
    #| B<set-directive>,
    #| B<delete-directive>,
    #| B<set-player>,
    #| and B<delete-player>.
    #| Calls B<change-callback>.
    method changed { &!change-callback(); self; }

    ######################################
    #
    #   directives methods
    #
    #| Return the array of B<directives>.
    multi method directives { %!directives.values }

    method !_set-directive (Games::Go::AGA::Objects::Directive $directive) {
        %!directives{$directive.key.tclc} = $directive;
        my &prev-callback = $directive.change-callback;
        my $register = self;
        $directive.set-change-callback(
            sub {
                &prev-callback();    # call directives previous callback
                $register.changed;  # call our own changed callback
            }
        );
        $.changed;
        self;
    }
    #| Add or replace a directive.
    multi method set-directive (Games::Go::AGA::Objects::Directive $directive) {
        self!_set-directive($directive);
    }
    #| Add or replace a directive.
    multi method set-directive (Str $key, Str $value, Str $comment? = '') { #=
        self!_set-directive(
            Games::Go::AGA::Objects::Directive.new(
                key     => $key,
                value   => $value // '1',
                comment => $comment,
            ),
        );
    }
    #| Add or replace a directive.
    multi method set-directive (Str $str) { #=
        $str.match(/^ \s* (\w+) \h+ (<-[#]>*) \h* (.*)/);
        die 'Not a valid directive' without $0;
        self!_set-directive(
            Games::Go::AGA::Objects::Directive.new(
                key     => ~$0,
                value   => ~$1,
                comment => ~$2,
            ),
        );
    }

    #| Return directive by B<key> name.
    method directive (Str $key) { #=
        %!directives{$key.tclc};
    }

    #| Delete directive by B<key> name.
    method delete-directive (Str $key) { #=
        %!directives{$key.tclc}:delete;
        $.changed;
        self;
    }

    ######################################
    #
    #   player methods
    #
    #| Return the array of players.
    multi method players { %!players.values; } #=

    #| Add a new player.  Throws and exception if ID already exists.
    method add-player (Games::Go::AGA::Objects::Player $player) { self!_add-player($player) } #=
    method !_add-player (Games::Go::AGA::Objects::Player $player) {
        my $id = $player.id;
        die "Duplicate ID $id" if %!players{$id}.defined;
        %!players{$id} = $player;
        my &prev-callback = $player.change-callback;
        $player.set-change-callback(
            sub {
                &prev-callback();    # call players previous callback
                $.changed;          # call our own changed callback
            }
        );
        $.changed;
        self;
    }

    #| Return the player with B<$id>.
    method player (AGA-Id $id) {
        %!players{$id};
    }

    #| Delete the player with B<$id>.
    method delete-player (Str $id) {
        %!players{$id}:delete;
        $.changed;
        self;
    }

    ######################################
    #
    #   comment methods
    #
    #| Add a comment.
    method add-comment (Str $comment) { self!_add-comment($comment) }
    method !_add-comment (Str $comment) {
        my @comments = $comment.split("\n");    # multi-line?
        for @comments -> $comment {
            # ensure each line is valid comment
            $comment ~~ / ^^ (\h*) ('#'*) (.*) /;
            push @!comments, $1 eq '#'
                  ?? $comment   # no change
                  !! "$0# $2";
        }
        $.changed;
        self;
    }

    #| Get comment by index.
    multi method comment (Int $idx) { #=
        @!comments[$idx];
    }
    #| Get comment by matching a Regex.
    multi method comment (Regex $re) { #=
        @!comments.grep($re);
    }

    #| Delete comment by index.
    multi method delete-comment (Int $idx) { #=
        @!comments.delete($idx);
        $.changed;
        self;
    }

    #| Delete comment by matching a Regex.
    multi method delete-comment (Regex $re) { #=
        @!comments = @!comments.grep({ not $_.match($re) });
        $.changed;
        self;
    }

    ######################################
    #
    #   other methods
    #
    #| Returns the Register information printed into a string, suitable for
    #| writing to C<register.tde>.
    method sprint {
        my @sprint.append(
            @!comments,
        ).append(
            %!directives.sort.map({ .value.sprint }),
        ).append(
            %!players.sort({ $^b.value.rating cmp $^a.value.rating }).map({ .value.sprint }),
        ).join("\n");
    }
}

=begin pod
=head1 SEE ALSO

=item L<Games::Go::AGA::Objects::Types>
=item L<Games::Go::AGA::Objects::Directive>
=item L<Games::Go::AGA::Objects::Player>

=end pod

# vim: expandtab shiftwidth=4 ft=perl6
