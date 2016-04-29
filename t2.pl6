use v6;
class B { multi submethod BUILD ($a) {}; multi submethod BUILD (:$b) {} }; B.new( 'B' );
