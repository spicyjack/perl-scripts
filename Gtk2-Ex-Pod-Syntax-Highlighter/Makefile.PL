use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Gtk2::Ex::Pod::Syntax::Highlighter',
    AUTHOR              => 'Brian Manning <bmanning@qualcomm.com>',
    VERSION_FROM        => 'lib/Gtk2/Ex/Pod/Syntax/Highlighter.pm',
    ABSTRACT_FROM       => 'lib/Gtk2/Ex/Pod/Syntax/Highlighter.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Gtk2-Ex-Pod-Syntax-Highlighter-*' },
);
