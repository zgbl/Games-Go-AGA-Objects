################################################################################
# ABSTRACT:  test for valid META6.json file
#
#   AUTHOR:  Reid Augustin
#    EMAIL:  reid@HelloSix.com
#  CREATED:  05/11/2016 10:36:38 AM
################################################################################

use v6;
use lib 'lib';
use Test;
plan 1;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>; 

if AUTHOR { 
    require Test::META <&meta-ok>;
    meta-ok;
    done-testing;
}
else {
     skip-rest "Skipping author test";
     exit;
}
