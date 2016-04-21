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
    use Games::Go::AGA::Objects::Player;

    has  Str $!dbdname           = 'tdlistdb.sqlite',
    has  Str $!table-name        = 'tdlist',
    has  Str $!table-name-meta   = 'tdlist-meta',   # currently just latest update time
    has  Int $.max-update-errors = 10,              # before aborting update
    has  Str $.raw-filename      = 'TDList.txt',    # file to update from
    has  Str $.url               = 'https://www.usgo.org/ratings/TDListN.txt',
    has      $!fh;
    has Bool $.verbose           = 0,
    has      &.print-callback    = method { $.say };
    has      %!sth-lib;

    constant BUF_MAX  = 4096;   # buffer for when file has no EOLs

    # names and SQL declarations of the database columns, in order
    my @column-sql = (    # SQL for each column creation
        id         => 'VARCHAR NOT NULL PRIMARY KEY',
        last_name  => 'VARCHAR',
        first_name => 'VARCHAR',
        membership => 'VARCHAR',
        rank       => 'VARCHAR',
        date       => 'VARCHAR',
        club       => 'VARCHAR',
        state      => 'VARCHAR',
    );
    my %idx-by-columns = @column-sql.keys.pairs;
    my %columns-by-idx = %idx-by-columns.invert;

    my $usage = qq:to/END       # usage message when run as script

        TDListDB [ -tdlist_file filename ] [ -sqlite_file filename ]
                [ -url url | AGA ] [ -verbose ] [ -help ]

        Options may be abbreviated to their first letter.

        By default, TDListDB.pm updates from a file in the current
        directory named TDList.txt.  Specify -tdlist_file to update
        from a different file, or specify -url to update from a
        website.  -url AGA updates from the usual AGA website at
            https://www.usgo.org/ratings/TDListN.txt

        END

#   sub run {   # run as a script
#       my ($class) = @_;

#       require Getopt::Long;
#       Getopt::Long.import(qw( :config pass_through ));

#       exit 0 if (not GetOptions(
#           'tdlist_file=s', => \$raw-filename,   # update from file
#           'sqlite_file=s', => \$dbdname,        # sqlite file
#           'url=s',         => \$url,                          # URL to update from
#           'verbose',       => \$verbose,
#           'help'           => sub { print $usage; exit 0; },
#       ));

#       my $tdlist = $class.new( verbose => $verbose );
#       STDOUT.autoflush(1);

#       if ($url) {
#           if (uc $url ne 'AGA') {
#               $tdlist.url($url);
#           }
#           $url = $tdlist.url;
#           print "Updating $.dbdname from AGA ($url)\n";
#           $tdlist.update_from_AGA();
#           exit;
#       }
#       print "Updating $.dbdname from file ($.raw-filename)\n";
#       $tdlist.update_from_file($.raw-filename);
#   }

    method db {
        without $!db {
            $!db = DBI.connect(          # connect to your database, create if needed
                "dbi:SQLite:dbname=$!fname", # DSN: dbi, driver, database file
                "",                          # no user
                "",                          # no password
                {
                    AutoCommit => 1,
                    RaiseError => 1,         # complain if something goes wrong
                },
            );
            $!db-schema();  # make sure tables exists
            $!sth-init();    # initialize sth library
        }
        $!db;
    }

    # library of statement handles
    multi method set-sth-lib (Str $name, Str $new) { say "set-sth-lib('$name', '$new')"; %!sth{$name} = $new; }
    multi method sth-lib (Str $name) {
        my $sth = %!sth-lib{$name};
        without ($sth) {
            die("No SQL named $name in sth library\n");
        }
        if ($sth ~~ Str) {
            $sth = %!sth-lib{$name} = $.db.prepare($sth);
        }
        $sth;
    }

    method sth-init {
        ( # SQL query library
            select_by_name => "SELECT * FROM $!table-name WHERE last_name  = ? AND first_name = ?",
            insert_player  => "INSERT INTO $!table-name ({$.sql-columns}) VALUES ({$.sql-insert-qs})",
            update_id      => "UPDATE $!table-name SET {$.sql-update-qs} WHERE id = ?",
            select_id      => "SELECT * FROM $!table-name WHERE id = ?";
            # get/set DB update time
            select_time    => "SELECT update_time FROM $!table-name-meta WHERE key = 1",
            update_time    => "UPDATE $!table-name-meta SET update_time = ? WHERE key = 1",
        ).map({ $.set-sth-lib($_.key, $_.value) });
    }

    method db-schema {
        $.db.do("CREATE TABLE IF NOT EXISTS $!table-name ({$.sql-column-types})");
        $.db.do( qq:to/END/ );
            CREATE TABLE IF NOT EXISTS $!table-name-meta (
                key INTEGER PRIMARY KEY,
                update_time VARCHAR(20)
            )
            END
        $.db.do( qq:to/END/ );
            INSERT OR IGNORE INTO $!table-name-meta (
                key,
                update_time
            ) VALUES ( 1, 0 )
            END
    }

    method set-update-time (Int $time = localtime) { $.sth-lib('update_time').execute($time); }
    method update-time {
        my $sth = $.sth-lib('select_time');
        $sth.execute();
        my $time = $.sth.fetchall_arrayref();
        $time = $time[0][0];
        return $time || 0;
    }

    method select_id (Int $id) {
        my $sth = $.sth-lib('select_id');
        $.sth.execute($id);
        # ID is primary index, so can only be one - fetch into first array
        # element:
        my ($player) = $.sth.fetchall_arrayref;
        $player.[$.column_idx('rank')] += 0 if (is_Rating($player.[$.column_idx('rank')]));   # numify ratings
        $player[0];
    }

    method update_from_AGA {
        if (not $!ua) {
            $!ua = LWP::UserAgent.new;
        }

        $.my-print("Starting $!raw-filename fetch from $!url at {localtime}") if ($!verbose);
        $!ua.mirror($!url, $!raw-filename);
        $.my-print("... fetch done at {localtime}\n") if ($!verbose);
        $.update_from_file($!raw-filename);
    }

    method update_from_file (Str $filename = $!raw-filename) {
say "update_from_file($filename)";
        $!raw-filename = $filename;
        $.update_from_fh($filename.IO);
        self;
    }

    method update_from_fh (IO $fh) {
say "update_from_fh";
        $!fh = $fh;

        my $actions = Games::Go::AGA::Objects::TDList::Actions.new();

        $.my-print("Starting database update at {localtime}\n") if ($!verbose);
say "Starting database update at {localtime}\n";
        
        $.db.do('BEGIN');
        my @errors;
        while (@errors.elems < $.max-update-errors) {
            last if ($fh.eof);
            my $line = $fh.get;     # get next line from $fh
            next if ($line.not);

say "Line {$fh.ins}: $line";
            if ($!verbose) {
                $.my-print('.')  if ($fh.ins %% 1000);
                $.my-print("\n") if ($fh.ins %% 40000);
            }
            try {   # in case a line crashes, collect error but continue
say "parsing...";
                my $player = Games::Go::AGA::Objects::TDList::Grammar.parse($line, :actions($actions)).ast;
say "update {$player.id} {$player.last-name}, {$player.first-name}";
                $.check-dup-player($player);
            }
            CATCH {
                push @errors, $fh.ins => $_;
            }
        }
        $.db.do('COMMIT');  # make sure we do this!
        $.update_time(time);
say "database update done at {localtime}\n";
        if (@errors.elems) {
            die("{@errors.elems} errors - aborting:\n@errors");
        }
        self;
    }

    method check-dup-player (Games::Go::AGA::Objects::Player $player) {
say 'calling select_by_name';
        my $sth = $.sth-lib('select_by_name');
        $sth.execute($player.last-name, $player.first-name);
say 'execute complete';
        my $players = $.sth.fetchall_arrayref;
say 'fetchall_arrayref complete   dup player? TODO!';
        for $players -> $already {
            if ($already.id eq $player.id) {
                $.update-player($player);
                return self;
            }
            # TODO check/report other dups
        }
        # ID is not in database, insert new record
say 'inserting new record';
        $.sth-lib('insert_player').execute($.player-column-values($player));  # TODO
        self;
    }

    # ID is already in database, do an update
    method update-player (Games::Go::AGA::Objects::Player $player) {
        my $sth = $.sth-lib('update_id');
        $sth.execute($.player-column-values($player));
    }

    # sql columns with SQL types declarations
    method sql-column-types (Str $joiner = ', ') {
        @column-sql.kv.join($joiner);
    }

    # sql columns (without column types)
    method sql-columns (Str $joiner = ', ') {
        @column-sql.keys.join($joiner);
    }

    # '?, ' place-holder question marks for each column,
    #    appropriate for an UPDATE or INSERT query
    method sql-update-qs (Str $joiner = ', ') {
        @column-sql.map({$_.key ~ ' = ?'}).join($joiner);
    }

    # place-holder question marks for each column,
    #    appropriate for an INSERT query
    method sql-insert-qs (Str $joiner = ', ') {
        @column-sql.map('?').join($joiner);    # one question mark per column
    }

    method set-print-callback (&pcb) { &!change-callback = &pcb; self; };
    method my-print (*@a) { self.&!print-callback(@a); self; }
}

=head1 SYNOPSIS

  use Games::Go::AGA::Objects::TDListDB;

=head1 DESCRIPTION

B<Games::Go::AGA::TDListDB> builds a database (SQLite by default) of
information from the TDList file provided by the American Go Association.

An update method is available that can reach out to the AGA website and
grab the latest TDList information.

=head2 Accessors

All of the B<options> listed under the B<new> method (below) may also be
used as accessors.

=head2 Methods

=over

=item $tdlist = Games::Go::AGA::Objects::TDListDB.new( [ %options ] );

Creates a new TdListDB object.  The following options may be supplied (and
may also be accessed via functions of the same name):

=over

=item db => $db

If B<$db> (a perl DBI object) is supplied, it is used as the database
object handle, otherwise an SQLite DBI handle is created and used.

The return value is the DBI object you want to use for regular database
operations, such as inserting, updating, etc.  However, see also the
predefined statement handles (B<tdlist-E<gt>sth> below), the statement you
need may already be there.

=item dbdname => 'path/to/filename'

This is the SQLite database filename used when no B<db> object is supplied
to B<new>.  If the file does not exist, it is created and populated.  The
default filename is 'tdlistdb.sqlite'.

=item max-update-errors => integer

An B<update_from_file> or B<update_from_AGA> counts errors until this
number is reached, at which point the update gives up and throws an
exception.  The default value is 10.

=item url => 'http://where.to.find.tdlist'

The URL to retrieve TDList from.  The default is
'http://www.usgo.org/ratings/TDListN.txt'.

=item raw-filename => 'TDList.txta

When fetching from the AGA, the TDList data is dumped into this filename.
If this file already exists, and is newer than the data at the AGA, the
fetch is skipped (since the data should be the same - see perldoc
LWP::UserAgent B<mirror>).

=item table-name => 'DB_table_name'

The name of the database table.  An additional table (retrievable with
the B<table-name-meta> read-only accessor) is also created to hold the
table's B<update_time>.

When returning the table name, the value is always metaquoted.

The default table name is 'tdlistn'.

=item $tdlistdb.print_cb( [ \&callback ]

Set/get the print callback.  Whenever something is to be printed, the
B<callback> function is called with the print arguments.  B<callback>
defaults to the standard perl print function, and new B<callback> functions
should be written to take arguments the same way print does.

=back

=item $tdlistdb.my-print( @args )

Calls B<print-callback> with B<@args>.

=item $tdlistdb.column_idx( [ 'name' ] )

When 'name' is defined, it is lower-cased, and the column index for 'name' (or undef
if 'name' isn't one of the default column names) is returned.

When 'name' is not provided, returns an array (or ref to array in scalar context) of
the default column names, in order.

These are the default columns by name:

=over

=item last_name

=item first_name

=item id

=item membership

=item rank

=item date

=item club

=item state

=back

=item $tdlistdb.update_from_AGA( [ $force ] )

Reach out to the American Go Association (AGA) ratings web page and
grab the most recent TDList information.  Update the database.  May
throw an exception if the update fails for any of a number of reasons.

=item $tdlistdb.update_from_file( $file )

Updates the database from a file in TDList format.  Called by
B<update_from_AGA>.  B<$file> may be a file handle, or if it's a
string, it is the name of the file to open.  May throw an exception on
various file or formatting errors.

=item $sql = $tdlistdb.sql-columns( [ $joiner ])

Returns SQL suitable for the list of column names, separated by commas
(or something else if you set a B<$joiner>).  See INSERT and SELECT
queries.

=item $sql = $tdlistdb.sql-column-types( [ $joiner ])

Returns SQL suitable for the list of column names followed by the
column type, separated by commas (or something else if you set a
B<$joiner>).  See CREATE TABLE queries.

=item $sql = $tdlistdb.sql-update-qs( [ $joiner ])

Returns SQL suitable for the list of question-mark ('?') placeholders
for each column, separated by commas (or something else if you set a
B<$joiner>).  See UPDATE queries.

=item $sql = $tdlistdb.sql-insert-qs( [ $joiner ])

Returns SQL suitable for the list of "column = ?" placeholders,
separated by commas (or something else if you set a B<$joiner>).  See
INSERT queries.

=item $id = $tdlistdb.update_time( [ $seconds ] )

Get or set the time (in seconds) the database was last updated (via
B<update_from_AGA> or B<update_from_file>).

=item @player_fields = $tdlistdb.select_id( 'id_string' )

Returns the array (or ref to array in scalar context) of the player with ID
equal to 'id_string', or an empty array of 'id_string' is not found.

=item $sth = $tdlistdb.sth('handle_name', [ $DBI::sth ] )

B<Games::Go::AGA::Objects::TDListDB> maintains a small library of prepared DBI
statement handles, available by name.  You may add to the list, but
take care not to overwrite existing names if you want this module to
continue working correctly.  The predefined handles are:

=over

=item $tdlistdb.sth('select_by_name').execute('last name', 'first name')

Find a player by last name and first name.  Note that the ID is the
'PRIMARY KEY' for the database, and that last and first names may not
be unique.

=item $tdlistdb.sth('insert_player').execute(@new_column_values)

Add a new player to the database.  @new_column_values are values for all
the columns.

Returns the @new_column_values array (or a reference to it in scalar
context), with the new ID if it was set.

=item $tdlistdb.sth('update_id').execute(@new_column_values, 'ID')

Update a player already in the database.  @new_column_values are values for
all the columns, and ID is the player's
unique ID.  Note that a new ID is also in the @new_column_values.  These
should differ only under exceptional circumstances, such as if a TMP player
gets a real AGA ID.

=item $tdlistdb.sth('select_id').execute('ID');

Find a player by ID.  Note that the ID is the 'PRIMARY KEY' for the
database, so this query will return only one record.

=item $tdlistdb.sth('select_time').execute();

Get the current database update time (but use B<update_time()> instead).

=item $tdlistdb.sth('update_time').execute($new);

Set the current database update time (but use B<update_time($new)> instead).

=back

=back

=head1 SEE ALSO

=over

=item Games::Go::AGA::Parse

Parsers for AGA format files.

=item Games::Go::Wgtd

Online go tournament system.

=back

