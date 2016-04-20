#!/usr/bin/env perl6
################################################################################
#         FILE:  Games::Go::AGA::Objects::TDListDB
#     ABSTRACT:  a database for holding AGA TDList data
#       AUTHOR:  Reid Augustin (REID), <reid@hellosix.com>
#      CREATED:  Tue Apr 19 18:31:32 PDT 2016
################################################################################
use v6;

use DBIish;

our $VERSION = '0.001'; # VERSION

class Games::Go::AGA::Objects::TDListDB;
    has  Str $.url               = 'https://www.usgo.org/ratings/TDListN.txt',
    has  Str $!dbdname           = 'tdlistdb.sqlite',
    has  Str $!table-name        = 'tdlist',
    has  Int $.max-update-errors = 10,
    has  Str $.raw-filename      = 'TDList.txt',
    has Bool $.verbose           = 0,
    has      %!sth-lib           = ( # SQL query library
        select_by_name  => "SELECT * FROM $!table-name WHERE last_name  = ? AND first_name = ?",
        insert_player   => "INSERT INTO $!table-name ({$.sql_columns}) VALUES ({$.sql_insert_qs})",
        update_id       => "UPDATE $!table-name SET {$.sql_update_qs} WHERE id = ?",
        select_id       => "SELECT * FROM $!table-name WHERE id = ?";
        # get/set DB update time
        select_time     => "SELECT update_time FROM $!table_name_meta WHERE key = 1",
        update_time     => "UPDATE $!table_name_meta SET update_time = ? WHERE key = 1",
    );

    constant $BUF_MAX  = 4096;

    # list the names of the database field columns/subroutines, in order
    my @column-sql = (    # SQL for each column creation
        id         => 'VARCHAR NOT NULL PRIMARY KEY',
        last_name  => 'VARCHAR',
        first_name => 'VARCHAR',
        membership => 'VARCHAR',
        rank       => 'VARCHAR',
        date       => 'VARCHAR',
        club       => 'VARCHAR',
        state      => 'VARCHAR',
        extra      => 'VARCHAR',
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

    sub run {   # run as a script
        my ($class) = @_;

        require Getopt::Long;
        Getopt::Long.import(qw( :config pass_through ));

        exit 0 if (not GetOptions(
            'tdlist_file=s', => \$raw-filename,   # update from file
            'sqlite_file=s', => \$dbdname,        # sqlite file
            'url=s',         => \$url,                          # URL to update from
            'verbose',       => \$verbose,
            'help'           => sub { print $usage; exit 0; },
        ));

        my $tdlist = $class.new( verbose => $verbose );
        STDOUT.autoflush(1);

        if ($url) {
            if (uc $url ne 'AGA') {
                $tdlist.url($url);
            }
            $url = $tdlist.url;
            print "Updating $.dbdname from AGA ($url)\n";
            $tdlist.update_from_AGA();
            exit;
        }
        print "Updating $.dbdname from file ($.raw-filename)\n";
        $tdlist.update_from_file($.raw-filename);
    }

    method db is cached {
        $!db = DBI.connect(          # connect to your database, create if needed
            "dbi:SQLite:dbname=$!fname", # DSN: dbi, driver, database file
            "",                          # no user
            "",                          # no password
            {
                AutoCommit => 1,
                RaiseError => 1,         # complain if something goes wrong
            },
        )
        $!db-schema();   # make sure tables exists
        $!db;
    }

    # library of statement handles
    multi method set-sth-lib (Str $name, $new) { %!sth{$name} = $new; }
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

    sub db-schema {
        my ($self) = @_;

        $.db.do("CREATE TABLE IF NOT EXISTS $!table-name ({$.sql_column_types})");
        $.db.do(qq:to/END
            CREATE TABLE IF NOT EXISTS $!table_name_meta (
                key INTEGER PRIMARY KEY,
                update_time VARCHAR(12),
            END
        );

        $.db.do(qq:to/END
            INSERT OR IGNORE INTO $!table_name_meta (
                key,
                update_time,
            ) VALUES ( 1, 0, 1 )
            END
        );
    }

    method set-update-time (Int $time = localtime) { $.sth-lib('update_time').execute($new); }
    method update-time {
        my $sth = $.sth-lib('select_time');
        $sth.execute();
        my $time = $.sth.fetchall_arrayref();
        $time = $time[0][0];
        return $time || 0;
    }

    method select_id (Int $id) {
        my ($self, $id) = @_;

        my $sth = $.sth-lib('select_id');
        $.sth.execute($id);
        # ID is primary index, so can only be one - fetch into first array
        # element:
        my ($player) = $.sth.fetchall_arrayref;
        $player.[$.column_idx('rank')] += 0 if (is_Rating($player.[$.column_idx('rank')]));   # numify ratings
        $player[0];
    }

    sub update_from_AGA {
        my ($self) = @_;

        if (not $!ua) {
            $!ua = LWP::UserAgent.new;
        }

        $.my_print("Starting $!raw-filename fetch from $!url at {localtime}") if ($!verbose);
        $!ua.mirror($!url, $!raw-filename);
        $.my_print("... fetch done at {localtime}\n") if ($!verbose);
        $.update_from_file($!raw-filename);
    }

    method update_from_file (Str $filename = $!raw-filename) {
say "update_from_file($filename)";
        $!raw-filename = $filename;
        $.update_from_fh($filename.IO); }
        self;
    }

    method update_from_fh (IO $fh) {
say "update_from_fh";
        $!fh = $fh;
        $!oef = 0;

        my $actions = Games::Go::AGA::Objects::TDList::Actions.new();

        $.my_print("Starting database update at ", scalar localtime, "\n") if ($!verbose);
say "Version $VERSION Starting database update at ", scalar localtime, "\n";
        $.db.do('BEGIN');
        my @errors;
        my $ii = 0;
        my $ID = $.column_idx('id');
        while (@error.elems < $.max-update-errors) {
            $ii++;
            my $line = $.next-line-from-fh;
            last if ($!oef);
            next if ($line.not);

say "Line $ii: $line";
say '.'  if ($ii %% 10000);
            if ($!verbose) {
                $.my_print('.')  if ($ii %% 1000);
                $.my_print("\n") if ($ii %% 40000);
            }
            try {   # in case a line crashes, print error but continue
                #$.my_print("parse $line") if ($!verbose);
say "parsing...";
                my $player = Games::Go::AGA::Objects::TDList::Grammar.parse($line, :actions($actions)).ast;
say "update {$player.id} {$player.last-name}, {$player.first-name}";
                $.update_player($player);
            }
            CATCH {
                push @errors, $ii => $_;
            }
        }
        $.db.do('COMMIT');  # make sure we do this!
        $.update_time(time);
say "database update done at {localtime}\n";
        if (@error.elems) {
            die("{@error.elems} errors - aborting:\n@errors");
        }
        self;
    }

    method check-dup-player (Games::Go::AGA::Objects::Player $player) {
say 'calling select_by_name';
        my $sth = $.sth-lib('select_by_name');
        $sth.execute($player.last-name, $player.first-name);
say 'execute complete';
        my $players = $.sth.fetchall_arrayref;
say 'fetchall_arrayref complete';
say '   dup player? TODO!'
        for $players -> $already {
            if ($already.id eq $player.id) {
                $update-player($player);
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
        $sth->execute($.player-column-values($player);
    }


ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ

    # file might not have lines.  enforce lines here
    sub next-line-from-fh {
        my ($self) = @_;

        my $offset = $.{buf_offset};
        if ($.{buf_end} - $offset <= 160) {
            $.get_fh_chunk;
            $offset = $.{buf_offset};
        }
        return if ($offset >= $.{buf_end});
        my $eol_idx;
        if ($.{has_lines}) {
            $eol_idx = index($.{buf}, "\n", $offset);
            if ($eol_idx < 0) {
                die "no EOL";       # shouldn't happen
            }
        }
        else {
            # assume 80 characters per line
            $eol_idx = $offset + 80;
            # but not past the end of the buffer
            $eol_idx = $.{buf_end} if ($eol_idx > $.{buf_end});
            $eol_idx--;
        }
        my $len = $eol_idx - $offset;
        my $line = substr $.{buf}, $offset, $len;
        $.{buf_offset} += $len + 1;
        return $line;
    }

    sub fh {
        my ($self, $new) = @_;

        if (@_ > 1) {
            $.{fh} = $new;
            delete $.{has_lines};
            if ($new and ref $new) {
                $.{buf} = '';
                $.{buf_offset} = $.{buf_end} = 0;
                $.get_fh_chunk;
                $.{has_lines} = (index($.{buf}, "\n") >= 0);
            }
        }
        return $.{fh};
    }

    sub get_fh_chunk {
        my ($self) = @_;

        # how much is still left?
        my $left = $.{buf_end} - $.{buf_offset};
        # shift unused part of buf down to the beginning
        substr($.{buf}, 0, $.{buf_offset}, '');
        # read in a new chunk
        my $new = read $.fh, $.{buf}, $BUF_MAX - $left, $left;
        if (not defined $new) {
            die "Read error: $!";
        }
        $.{buf_end} = $left + $new;
        $.{buf_offset} = 0;
    }

    # sql columns (without column types)
    sub sql_columns {
        my ($self, $joiner) = @_;

        $joiner = ', ' if (not defined $joiner);
        return join($joiner,
            map({ keys %{$_} }
                @columns,
                $.extra_columns,
            ),
        );
    }

    # sql columns with column types
    sub sql_column_types {
        my ($self, $joiner) = @_;

        $joiner = ', ' if (not defined $joiner);

        return join($joiner,
            map({join ' ', each %{$_}}
                @columns,
                $.extra_columns,
            ),
        );
    }

    # '?, ' place-holder question marks for each column,
    #    appropriate for an UPDATE or INSERT query
    sub sql_update_qs {
        my ($self, $joiner) = @_;

        $joiner = ', ' if (not defined $joiner);

        return join($joiner,
            map({ (keys(%{$_}))[0] . ' = ?' }
                @columns,
                $.extra_columns,
            ),
        );
    }

    # place-holder question marks for each column,
    #    appropriate for an INSERT query
    sub sql_insert_qs {
        my ($self, $joiner) = @_;

        $joiner = ', ' if (not defined $joiner);

        return join($joiner,
            map({ '?' }     # one question mark per column
                @columns,
                $.extra_columns,
            ),
        );
    }

    sub my_print {
        my $self = shift;

        $.print_cb.(@_);
    }

    sub print_cb {
        my ($self, $new) = @_;

        $.{print_cb} = $new if (@_ > 1);
        return $.{print_cb} || sub { print @_ };
    }
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
the B<table_name_meta> read-only accessor) is also created to hold the
table's B<update_time>.

When returning the table name, the value is always metaquoted.

The default table name is 'tdlistn'.

=item extra_columns => [ {column_name => column_TYPE}, ... ]

If you need extra columns in the database, add the names/column types here.
They are used only in the creation of the table schema if the database doesn't
already exist.  The default columns are:

    {last_name  => 'VARCHAR(256)'        },
    {first_name => 'VARCHAR(256)'        },
    {id         => 'INTEGER PRIMARY KEY' },
    {membership => 'VARCHAR(256)'        },
    {rank       => 'VARCHAR(256)'        },
    {date       => 'VARCHAR(256)'        },
    {club       => 'VARCHAR(256)'        },
    {state      => 'VARCHAR(256)'        },
    {extra      => 'VARCHAR(256)'        },

which are the columns found in TDList.txt from the AGA.  When defining
extra columns, take care to set a proper SQL column type and not to overlap
these existing names.

To fill in these extra columns, you might want to use:

=item extra_columns_callback => sub { ...; return @column_values; }

This callback is called for each record added (or updated) to the database
during B<update_from_AGA> or B<update_from_file>. It is called with the
object pointer, and a ref to an array containing the values of the default
columns as listed above.  It should return an array of the values for the
extra columns in the same order as given in B<extra_columns>.
Alternatively, it can directly append those values onto the passed in array
ref.

    extra_columns          => [ 'rank_range' ], # name(s) for the extra column(s)
    extra_columns_callback => sub {
        my ($self, $columns) = @_;
        # add extra column indicating Dan or kyu
        return '' if not $columns.[$self.column_idx('rank')];
        return 'Dan' if Rank_to_Rating( $columns.[$self.column_idx('rank')] ) > 0;
        return 'Kyu';
    }

This function should always return exactly the number of extra columns defined in
the extra_columns option - the returned value may be the empty string ('').

=item $tdlistdb.print_cb( [ \&callback ]

Set/get the print callback.  Whenever something is to be printed, the
B<callback> function is called with the print arguments.  B<callback>
defaults to the standard perl print function, and new B<callback> functions
should be written to take arguments the same way print does.

=back

=item $tdlistdb.my_print( @args )

Calls the B<my_print> B<callback> with B<@args>.

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

=item extra

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

=item $sql = $tdlistdb.sql_columns( [ $joiner ])

Returns SQL suitable for the list of column names, separated by commas
(or something else if you set a B<$joiner>).  See INSERT and SELECT
queries.

=item $sql = $tdlistdb.sql_column_types( [ $joiner ])

Returns SQL suitable for the list of column names followed by the
column type, separated by commas (or something else if you set a
B<$joiner>).  See CREATE TABLE queries.

=item $sql = $tdlistdb.sql_update_qs( [ $joiner ])

Returns SQL suitable for the list of question-mark ('?') placeholders
for each column, separated by commas (or something else if you set a
B<$joiner>).  See UPDATE queries.

=item $sql = $tdlistdb.sql_insert_qs( [ $joiner ])

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
the columns, both built-in and B<extra_columns>.

Returns the @new_column_values array (or a reference to it in scalar
context), with the new ID if it was set.

=item $tdlistdb.sth('update_id').execute(@new_column_values, 'ID')

Update a player already in the database.  @new_column_values are values for
all the columns, both built-in and B<extra_columns>, and ID is the player's
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

