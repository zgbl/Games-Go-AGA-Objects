# Games::Go::AGA::Objects

Provides object definitions (and parsers) for various file formats defined
by the American Go Association (AGA).

This perl 6 implementation collects several perl 5 CPAN modules into one
consistant group:

    Games::Go::AGA::DataObjects
    Games::Go::AGA::Parse
    Games::Go::AGA::TDListDB

The AGA files handled by this package are:

    register.tde        tournament registration => Register.pm6
    1.tde, 2.tde, etc   round results           => Round.pm6
    TDListN.txt         AGA registered players  => TDListDB.pm

Grammers and Actions are included to parse these files and create the
objects.

Each object includes an `sprint` method suitable for printing back to a
file.
