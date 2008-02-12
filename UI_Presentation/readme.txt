User Interfaces in Perl Presentation Materials
San Diego Perl Mongers, February 2008

Presented by: Brian Manning <elspicyjack at gmail dot com>

This is the presentation itself, the 'presentation viewer', and the scripts
demonstrated for the presentation.  In order to get the examples to work, you
will have to change the paths listed in 'examples.json' to match where you
have placed the examples on your system, then run 'demo.pl', which is used to
launch the other examples.  You can also launch the other examples by hand
by calling them as 'perl example.pl'.

The presentation can be viewed by calling the 'slideshow.xul' file in a
browser; the URL would look something like this:

file:///path/to/slideshow.xul?data=sdpm-feb2008.txt?eva=true

or online, it would look something like this:

http://www.somehost.com/slideshow.xul?data=sdpm-feb2008.txt?eva=true

Use the arrow keys on the keyboard to move around.  You can also call...

file:///path/to/slideshow.xul?data=help.txt 

to get the presentation help file, which explains how to use it much better
than I want to here.

Presentation Credits:

WHAT:   The presentation viewer, 'Takahashi-Method-based' XUL presentation
        tool
WHY:    Plain text file that is rendered in a Firefox/Mozilla window using
        JavaScript and XUL
WHERE:  http://piro.sakura.ne.jp/

WHAT:   demo.pl
WHY:    demo.pl is a demo of JSON, AppConfig, Log4perl, and Term::ShellUI; it
        is basically a launcher for all of the other examples.
WHERE:
http://cvs.antlinux.com/cvsweb.cgi/perl_scripts/UI_Presentation/examples/demo.pl
http://search.cpan.org/author/BRONSON/Term-ShellUI-0.86/lib/Term/ShellUI.pm

WHAT:   log4perl.pl
WHY:    A quick demo of Log4perl
WHERE:
http://search.cpan.org/author/MSCHILLI/Log-Log4perl-1.14/lib/Log/Log4perl.pm
http://cvs.antlinux.com/cvsweb.cgi/perl_scripts/UI_Presentation/examples/log4perl.pl

WHAT:   examples.json 
WHY:    a list of examples in JSON (JavaScript Object Notation) format.  The
        list is parsed by 'demo.pl'; if you plan on trying the demo script,
        change the paths to the other examples in examples.json for the
        platform you are running the demos on
WHERE:  http://en.wikipedia.org/JSON, 
        http://www.json.org
        http://search.cpan.org/author/MAKAMAKA/JSON-2.06/lib/JSON.pm
        http://cvs.antlinux.com/cvsweb.cgi/perl_scripts/UI_Presentation/examples/examples.json

WHAT:   widget
WHY:    The do-everything example for the Tk toolkit.  Install the Perl-TK
        bindings to get this program.
WHERE:  http://search.cpan.org/~ni-s/Tk-804.027/pod/UserGuide.pod

WHAT:   Gtk2-Perl 
WHY:    GTK2 bindings for Perl; canvas.pl (Gnome2-Canvas); simplelist.pl,
        calendar.pl, colorlist.pl, layout.pl (Gtk2); hello-world.pl,
        scribble.pl (Gtk2-GladeXML); the examples come from the tarballs
        listed in parenthesis above
WHERE   http://gtk2-perl.sourceforge.net
        http://search.cpan.org/author/TSCH/Gtk2-1.164/Gtk2.pm

WHAT:   gyroscope
WHY:    my Gtk2 demo, replacing a C program of the same name that fell off of
        the internet
WHERE:  http://cvs.antlinux.com/cvsweb.cgi/perl_scripts/gyroscope.pl

WHAT:   Notepad.pl, MonthCal.pl, Draw.pl
WHY:    Examples from Win32::GUI; Win32::GUI is available via Cygwin's
        installer
WHERE:  http://www.cygwin.com,
        http://search.cpan.org/author/ROBERTMAY/Win32-GUI-1.05/docs/GUI.pod

WHAT:   dclock.pl, buttongroups.pl, helloworld_qt.pl
WHY:    Examples of Perl::Qt3
WHERE:  http://perlqt.sourceforge.net,
        http://search.cpan.org/~ggarand/PerlQt-3.008/

WHAT:   testmenu.pl
WHY:    SDL_Perl demo
WHERE:  http://search.cpan.org/author/DGOEHRIG/SDL_Perl-2.1.3/lib/SDL.pm,
        http://sdl.perl.org

WHAT    Frozen Bubble
WHY:    A real game written in Perl_SDL.  And fun too!
WHERE:  http://www.frozen-bubble.org/

WHAT:   helloworld_ui-dialog.pl
WHY:    An example of multiple modes of UI::Dialog; you'll need at least one
        of the following external binaries installed: dialog, whiptail,
        gdialog, xdialog, zenity
WHERE:  http://search.cpan.org/author/KCK/UI-Dialog-1.08/lib/UI/Dialog.pod

Honorable mentions (things I wanted to get working but couldn't):

- Camelbones (http://camelbones.sourceforge.net/) - OS X
- wxPerl (http://wxperl.eu/download.html) - Windows/Linux/OS X
- FLTK (Fast Light Toolkit, http://www.fltk.org/) - Source only 
