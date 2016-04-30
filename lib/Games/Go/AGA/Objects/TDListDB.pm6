#!/usr/bin/env perl6
################################################################################
#         FILE:  Games::Go::AGA::Objects::TDListDB
#     ABSTRACT:  a database for holding AGA TDList data
#       AUTHOR:  Reid Augustin (REID), <reid@hellosix.com>
#      CREATED:  Tue Apr 19 18:31:32 PDT 2016
################################################################################
use v6;

use DBIish;

class Games::Go::AGA::Objects::TDListDB {
    use Games::Go::AGA::Objects::TDList::Actions;
    use Games::Go::AGA::Objects::TDList::Grammar;
    use Games::Go::AGA::Objects::Player;

    has      $.dbh;                                 # initialized in method $.dbh or $.sth-lib
    has  Str $.db-filename       = 'tdlistdb.sqlite';
    has  Str $.table-name        = 'tdlist';
    has  Str $.table-name-meta   = 'tdlist_meta';   # currently just latest update time
    has  Str $.tdlist-filename   = 'TDList.txt';    # file to update from
    has  Str $.url               = 'https://www.usgo.org/ratings/TDListN.txt';
    has  Int $.max-update-errors = 10;              # before aborting update
    has      $.actions           = Games::Go::AGA::Objects::TDList::Actions.new;
    has Bool $.verbose           = False;
    has      &.print-callback    = method (*@a) { say(|@a) };
    has      $!fh;
    has      %!sth-lib;

    # names and SQL declarations of the database columns, in order
    my Pair @column-sql = (    # SQL for each column creation
        id              => 'VARCHAR NOT NULL PRIMARY KEY',
        last_name       => 'VARCHAR NOT NULL',
        first_name      => 'VARCHAR',
        rating          => 'VARCHAR',
        club            => 'VARCHAR',
        state           => 'VARCHAR',
        membership_type => 'VARCHAR',
        membership_date => 'VARCHAR',   # expiration
    );

    my $usage = qq:to/END/;     # usage message when run as script

        TDListDB [ -tdlist_file filename ] [ -sqlite_file filename ]
                [ -url url | AGA ] [ -verbose ] [ -help ]

        Options may be abbreviated to their first letter.

        By default, TDListDB.pm updates from a file in the current
        directory named TDList.txt.  Specify -tdlist_file to update
        from a different file, or specify -url to update from a
        website.  -url AGA updates from the usual AGA website at
            https://www.usgo.org/ratings/TDListN.txt

        END

    # set accessors:
    method set-dbh ($dbh)                                 {$!dbh = $dbh; self};
    method set-dbdname (Str $db-filename)                 {$!db-filename = $db-filename; self}
    method set-table-name (Str $table-name)               {$!table-name = $table-name; self}
    method set-table-name-meta (Str $table-name-meta)     {$!table-name-meta = $table-name-meta; self}
    method set-raw-filename (Str $tdlist-filename)        {$!tdlist-filename = $tdlist-filename; self}
    method set-url (Str $url)                             {$!url = $url; self}
    method set-max-update-errors (Int $max-update-errors) {$!max-update-errors = $max-update-errors; self}
    method set-actions ($actions)                         {$!actions = $actions; self}
    method set-verbose (Bool $verbose)                    {$!verbose = $verbose; self}

my $ii = 0;

#   sub run {   # run as a script
#       my ($class) = @_;

#       require Getopt::Long;
#       Getopt::Long.import(qw( :config pass_through ));

#       exit 0 if (not GetOptions(
#           'tdlist_file=s', => \$tdlist-filename, # update from file
#           'sqlite_file=s', => \$db-filename,    # sqlite file
#           'url=s',         => \$url,            # URL to update from
#           'verbose',       => \$verbose,
#           'help'           => sub { print $usage; exit 0; },
#       ));

#       my $tdlist = $class.new( verbose => $verbose );
#       STDOUT.autoflush(1);

#       if $url {
#           if uc $url ne 'AGA' {
#               $tdlist.url($url);
#           }
#           $url = $tdlist.url;
#           print "Updating $.db-filename from AGA ($url)\n";
#           $tdlist.update-from-url();
#           exit;
#       }
#       print "Updating $.db-filename from file ($.tdlist-filename)\n";
#       $tdlist.update-from-file($.tdlist-filename);
#   }

    method dbh {
        without $!dbh {
            $!dbh = DBIish.connect(         # connect to your database, create if needed
                'SQLite',                   # driver
                :database($!db-filename),   # database file
             #  :AutoCommit,
             #  :RaiseError,                # complain if something goes wrong
            );
            $.db-schema;    # make sure tables exists
            $.sth-init;     # initialize sth library
        }
        $!dbh;
    }

    method db-schema {
        $.dbh.do("CREATE TABLE IF NOT EXISTS $!table-name ({$.sql-column-types})");
        $.dbh.do( qq:to/END/ );
            CREATE TABLE IF NOT EXISTS $!table-name-meta (
                key INTEGER PRIMARY KEY,
                update_time VARCHAR(20)
            )
            END
        $.dbh.do( qq:to/END/ );
            INSERT OR IGNORE INTO $!table-name-meta (
                key,
                update_time
            ) VALUES ( 1, { time } )
            END
        self;
    }

    method sth-init {
        my @pairs = # SQL query library
            select_by_id   => "SELECT * FROM $!table-name WHERE id = ?",
            select_by_name => "SELECT * FROM $!table-name WHERE last_name = ? AND first_name = ?",
            insert_player  => "INSERT INTO $!table-name ({$.sql-columns}) VALUES ({$.sql-insert-qs})",
            update_id      => "UPDATE $!table-name SET {$.sql-update-qs} WHERE id = ?",
            select_id      => "SELECT * FROM $!table-name WHERE id = ?",
            # get/set DB update time (but use update-time and set-update-time methods instead)
            select_time    => "SELECT update_time FROM $!table-name-meta WHERE key = 1",
            update_time    => "UPDATE $!table-name-meta SET update_time = ? WHERE key = 1",
        ;
        @pairs.map({ $.add-sth-lib( .key, .value) });
        self;
    }

    # library of statement handles
    multi method add-sth-lib (Str $name, Str $new) { %!sth-lib{$name} = $new; self }
    multi method sth-lib (Str $name) {
        without $.dbh { }   # initialize $.dbh if necessary
        my $sth = %!sth-lib{$name};
        without $sth {
            die("No SQL named $name in sth library");
        }
        if $sth ~~ Str {
            $sth = %!sth-lib{$name} = $.dbh.prepare($sth);
        }
        $sth;
    }

    # sql columns with SQL types declarations
    method sql-column-types (Str $joiner = ', ') {
        @column-sql.map({ .fmt('%s %s') }).join($joiner);
    }

    # sql columns (without column types)
    method sql-columns (Str $joiner = ', ') {
        @column-sql.map({ .keys }).join($joiner);
    }

    # col-name and '?, ' place-holder question mark for each column,
    #    appropriate for an UPDATE query
    method sql-update-qs (Str $joiner = ', ') {
        @column-sql.map({ .key ~ ' = ?'}).join($joiner);
    }

    # place-holder question marks for each column,
    #    appropriate for an INSERT query
    method sql-insert-qs (Str $joiner = ', ') {
        @column-sql.map({ '?' }).join($joiner);    # one question mark per column
    }

    method set-update-time (Int $time = time) { $.sth-lib('update_time').execute($time); self }
    method update-time {
        my $sth = $.sth-lib('select_time');
        $sth.execute;
        my $time = $sth.fetchall_arrayref;
        $time = $time[0][0];
        $time || 0;
    }

    method update-from-url {
        die "Sorry, can't update from URL yet";
        #  if not $!ua {
        #      $!ua = LWP::UserAgent.new;
        #  }

        #  $.my-print("Starting $!tdlist-filename fetch from $!url at {time}") if $!verbose;
        #  $!ua.mirror($!url, $!tdlist-filename);
        #  $.my-print("... fetch done at {time}\n") if $!verbose;
        #  $.update-from-file($!tdlist-filename);
        #  self
    }

    method update-from-file (Str $filename = $!tdlist-filename) {
        $!tdlist-filename = $filename;
        my $fh = open $filename, :r;
        $.update-from-fh($fh);
        self;
    }

    method update-from-fh (IO::Handle $fh) {
        $!fh = $fh;

        $.my-print("Starting database update at {time}\n") if $!verbose;
        $.dbh.do('BEGIN');
        my @errors;
        for $fh.lines -> $line {
            next if $line.not;    # skip empty line

            if $!verbose {
                $.my-print('.')  if $fh.ins %% 1000;
                $.my-print("\n") if $fh.ins %% 40000;
            }
            try {   # in case a line crashes, collect error but continue
                $.update-from-line($line);
            }
            CATCH {
                push @errors, $fh.ins => $_;
            }
            last if @errors.elems >= $.max-update-errors;
        }
        $.dbh.do('COMMIT');  # make sure we do this!
        $.set-update-time;
        if @errors.elems {
            die("{@errors.elems} errors - aborting:\n@errors");
        }
        self;
    }

    method update-from-line (Str $line) {
        my $player = Games::Go::AGA::Objects::TDList::Grammar.parse($line, :actions($!actions)).ast;
        with $player {
            $.insert-or-update-player($player);
        }
        self;
    }

    method insert-or-update-player (Games::Go::AGA::Objects::Player $player) {
        my $sth = $.sth-lib('select_by_id');
        $sth.execute($player.id);
        my $in-db = $sth.fetchall_arrayref[0];
        if $in-db.so {
            # ID is already in database, do an update
            $.sth-lib('update_id').execute(|$.player-column-values($player), $player.id);
            return self;
        }
        # ID is not in database, insert new record
        $.sth-lib('insert_player').execute(|$.player-column-values($player));
        self;
    }

    method player-column-values (Games::Go::AGA::Objects::Player $player, Str $joiner = ', ') {
        # return list of $player's values for each database column
        my @keys;
        for @column-sql -> $pair {
            my $key = $pair.key.subst(/_/, '-');    # SQL doesn't like dashes in names
            my $value = $player."$key"();
            $value = '' without $value;
            push @keys, $value.Str;
        }
        @keys;
    }

    method my-print (*@a) { self.&!print-callback(@a); self; }
}

sub MAIN ( Str $filename = 'TDList,txt' ) {
    Games::Go::AGA::Objects::TDListDB.new().update-from-file($filename);
}

=begin pod

=head1 SYNOPSIS

  use Games::Go::AGA::Objects::TDListDB;

=head1 DESCRIPTION

B<Games::Go::AGA::TDListDB> builds a database (SQLite by default) of
information from the TDList file provided by the American Go Association.
Update methods are available to update/insert database records by line,
by filehandle, by filename, or by URL.

A small selection of prepared SQL queries is stored in an extendable
library - see B<sth-lib> below.

=head2 Accessors and Options

The following attributes are defined with 'fetch' accessors.  Each of these
has a corresponding B<set-...> method, and they may be specified as named
options to B<new>:

    has      $.dbh;                                 # initialized in method $.dbh or $.sth-lib
    has  Str $.db-filename       = 'tdlistdb.sqlite';
    has  Str $.table-name        = 'tdlist';
    has  Str $.table-name-meta   = 'tdlist_meta';   # currently just latest update time
    has  Str $.tdlist-filename   = 'TDList.txt';    # file to update from
    has  Str $.url               = 'https://www.usgo.org/ratings/TDListN.txt';
    has  Int $.max-update-errors = 10;              # before aborting update
    has      $.actions           = Games::Go::AGA::Objects::TDList::Actions.new;
    has Bool $.verbose           = False;
    has      &.print-callback    = method (*@a) { say(|@a) };

=item dbh => DBIish-handle

If B<$dbh> (a DBIsh handle resulting from a B<connect> call) is supplied,
it is used as the database handle, otherwise an SQLite DBIish handle is
created and used.  See also the B<dbh> method below.

The return value is the DBIish handle you want to use for regular database
operations, such as B<do>, B<prepare>, etc.  However, see also the
predefined statement handles (B<sth-lib> below), the statement you need may
already be there.

=item db-filename => 'path/to/SQLite-filename'

This is the SQLite database filename used when no B<dbh> handle is
supplied.  If the file does not exist, it is created and populated.  The
default filename is 'tdlistdb.sqlite'.

=item table-name

=item table-name-meta

The name of the main database table, and an adjunct table to hold meta-data
(currently just the most recent B<update-time>)

The default table name is 'tdlistn'.

=item tdlist-filename => 'path/to/TDList.txt'

When fetching from a URL, the TDList data is dumped into this filename.
If this file already exists, and is newer than the data at the URL, the
fetch is skipped (see perldoc LWP::UserAgent B<mirror>).

=item url => 'http://where.to.find.tdlist'

The URL to retrieve TDList from.  The default is
'http://www.usgo.org/ratings/TDListN.txt'.

=item max-update-errors => integer

An B<update-from-file> or B<update-from-url> counts errors until this
number is reached, at which point the update gives up and throws an
exception.  The default value is 10.

=item actions => Actions::Object.new()

The Actions object to instantiate Player objects from
Games::Go::AGA::Objects::TDList::Grammar.parse.

=item verbose => Boolean

Print information verbosely when true.


=item print-callback => print-method

The print callback.  This module might be used where normal printing is not
proper (e.g: Dancer).  Whenever something is to be printed, the
B<print-callback> method is called with the B<say> arguments.
B<print-callback> defaults to the standard perl B<say> function. New
B<print-callback> functions should be written to take arguments the same
way B<say> does.

=head2 Methods

Methods without explicit return values return B<self>, enabling method
chaining.

=item dbh

Overrides the standard perl 6 B<$.dbh> read accessor.  If B<$!dbh> has not
been set (by an option to B<new>, or a previous call to B<dbh>), $!dbh is
set from the result of a DBIish.connect call using SQLite as the driver and
B<$!db-filename> as the database filename.

After connecting, calls B<$.db-schema> and B<$.sth-init>.  If you supply your
own B<dbh>, you should call these two methods by hand.

Returns B<$!dbh>, the database handle.

=item db-schema

Creates (if not already present) the database tables B<$!table-name> and
B<$!table-name-meta>.

=item sth-init

Prepares a small set of SQL statements.  Custom statement handles may be
added with B<add-sth-lib>.  Retrieve statement handles with B<sth-lib>
(below).  The following statements are available by default:

    select_by_id   => "SELECT * FROM $!table-name WHERE id = ?",
    select_by_name => "SELECT * FROM $!table-name WHERE last_name = ? AND first_name = ?",
    insert_player  => "INSERT INTO $!table-name ({$.sql-columns}) VALUES ({$.sql-insert-qs})",
    update_id      => "UPDATE $!table-name SET {$.sql-update-qs} WHERE id = ?",
    select_id      => "SELECT * FROM $!table-name WHERE id = ?";
    # get/set DB update time (but use update-time and set-update-time methods instead)
    select_time    => "SELECT update_time FROM $!table-name-meta WHERE key = 1",
    update_time    => "UPDATE $!table-name-meta SET update_time = ? WHERE key = 1",

See B<sql-columns>, B<sql-insert-qs> and B<sql-update-qs> below.

=item sth-lib(Str $name)

Retrieve prepared statement handles by name from the statement library.

=item sql-column-types ( [ Str $joiner = ', ' ] )

Returns a list of the table column names and their SQL initialization type (e.g: VARCHAR(256))
joined by B<$joiner>.  This list is used in B<db-schema> to create the tables.

These are the columns, in order:

    id              => 'VARCHAR NOT NULL PRIMARY KEY',
    last_name       => 'VARCHAR NOT NULL',
    first_name      => 'VARCHAR',
    rating          => 'VARCHAR',
    club            => 'VARCHAR',
    state           => 'VARCHAR',
    membership_type => 'VARCHAR',
    membership_date => 'VARCHAR',   # expiration

=item sql-columns ( [ Str $joiner = ', ' ] )

Returns a list of the table column names joined by B<$joiner>.  This list
is suitable for INSERT SQL statements (see B<insert-player> in B<sth-lib>).

=item sql-update-qs ( [ Str $joiner = ', ' ] )

Returns a list of question mark place holders, one for each table column,
joined by B<$joiner>.  This list is suitable for UPDATE SQL statements (see
B<update-id> in B<sth-lib>).

=item sql-insert-qs ( [ Str $joiner = ', ' ] )

Returns a list of question mark place holders, one for each table column,
joined by B<$joiner>.  This list is suitable for INSERT SQL statements (see
B<insert-player> in B<sth-lib>).

=item update-time
=item set-update-time ( [ Int $time = time ] )

Get/set the B<update-time> in the B<$!table-name-meta> table.  This time is
in seconds since the epoch.  If no time is passed to B<set-update-time>,
the current time is used.

=item update-from-url

Fetches the file from B<$!url>, loads it into B<$tdlist-filename>,
and calls B<update-from-file>.

=item update-from-file

Reads B<tdlist-filename> and calls B<$.update-from-line> on each line.  The
read / update loop is enclosed in a database BEGIN/COMMIT block, and calls
to B<update-from-line> are enclosed in a 'try' block.  Exceptions are
caught and counted, If the count exceeds B<$!max-update-errors>, the loop
is aborted, the database is COMMITed, and the errors are reported by
throwing another exception.

=item update-from-line ( Str $line )

Calls Games::Go::AGA::Objects::TDList::Grammer.parse( $line, :actions($!actions) ).ast
to create a new Games::Go::AGA::Objects::Player object.  Calls B<$.insert-or-update-player>
on each new Player.

=item insert-or-update-player ( Games::Go::AGA::Objects::Player $player )

Checks if the AGA ID of B<$player> is already in the database.  If so,
updates the player record and returns.  Otherwise, inserts the new player
into the database.

=item my-print( @args )

Calls B<print-callback> with B<@args>.

=head1 SEE ALSO

=item Games::Go::AGA::Objects::TDList::Grammar

=item Games::Go::AGA::Objects::TDList::Actions

=end pod

# vim: expandtab shiftwidth=4 ft=perl6
