################################################################################
# ABSTRACT:  tests for Games::Go::AGA::Objects::TDList
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@HelloSix.com
#  CREATED:  04/07/2016 12:41:54 PM
################################################################################

use 5.008;
use strict;
use warnings;

use IO::File;
use File::Spec;
use Readonly;

use Test::More
    tests => 4;

our $VERSION = '0.001'; # VERSION

use_ok 'Games::Go::AGA::Parse::TDList';   # the module under test
ok ( value ,                         'value is true');
is ( value ,    'abc',               'value is "abc"');



