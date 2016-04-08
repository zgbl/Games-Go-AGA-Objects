#!/usr/bin/perl
#===============================================================================
#      PODNAME:  Games::Go::AGA::Objects
#     ABSTRACT:  ?????
#
#       AUTHOR:  Reid Augustin (REID)
#        EMAIL:  reid@hellosix.com
#      CREATED:   
#===============================================================================

use 5.008;
use strict;
use warnings;

package Games::Go::AGA::Objects;

use open qw( :utf8 :std );  # UTF8 for all files and STDIO
use IO::File;
use File::Spec;
use Readonly;
use Getopt::Long qw(:config pass_through);

our $VERSION = '0.001'; # VERSION

use Exporter 'import';
our @EXPORT_OK = qw(
);

__PACKAGE__->run unless caller;     # modulino

sub run {
    my ($class) = @_;

    my (undef, undef, $myName) = File::Spec->splitpath($0);

    my $dir;            # directory
    my $filename;       # filename
    my $verbose;

    exit 0 if (not
        GetOptions(
            'dir=s'      => \$dir,
            'filename=s' => \$filename,
            'verbose'    => \$verbose,
        )
    );

    if (@ARGV and
        not $dir and
        -d $ARGV[0]) {
        $dir = shift @ARGV; # from cmd line even if --<opt> not explicit
    }
    if (@ARGV) {
        die(join(' ', "$myName: don't understand: ", @ARGV));
    }

    my %opts;
    $opts{dir}      = $dir if ($dir);
    $opts{filename} = $filename if ($filename);
    $opts{verbose}  = $verbose if ($verbose);

    $class->new(%opts);
}

sub new {
    my ($class, %opts) = @_;

    my $self = {};
    bless $self, (ref $class || $class);

    return $self;
}

sub foo {
    my ($self, $new) = @_;

    if (@_ > 1) {
        $self->{foo} = $new;
    }
    $self->{foo};
}

1;

=head1 SYNOPSIS

 use Games::Go::AGA::Objects;

=head1 DESCRIPTION

Games::Go::AGA::Objects represents...

=head2 Methods

=over

=item run

This module is a modulino, meaning it may be used as a module or as a
script.  The B<run> method is called when there is no caller and it is used
as a script.  B<run> parses the command line arguments, 
calls B<new()> to create the object...

=item new( [ options ] );

Creates a new Games::Go::AGA::Objects object.  The following options are available,
and are also available as accessors:

=over

=item option

=back

=item method()

=back

=head1 SEE ALSO

=over

=item SeeMe

=back

