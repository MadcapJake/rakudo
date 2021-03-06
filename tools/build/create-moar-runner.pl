#! perl6
# Copyright (C) 2013, The Perl Foundation.

use v6;

my ($moar, $mbc, $install_to, $p6_mbc_path, $toolchain, @libpaths) = @*ARGS;
$p6_mbc_path = $*SPEC.rel2abs($p6_mbc_path || $*SPEC.curdir);

if ($*DISTRO eq 'MSWin32') {
    exit if $toolchain;
    $install_to ~= '.bat';
    my $fh = open $install_to, :w;
    $fh.print(sprintf(qq[@ "%s" --execname="%%~dpf0" --libpath="%s" %s\\%s %%*\n],
            $moar, @libpaths.join('" --libpath="'), $p6_mbc_path, $mbc));
    $fh.close;
}
elsif ($toolchain eq 'gdb') {
    my $fh = open $install_to, :w;
    $fh.print(sprintf(q:to/EOS/, ($moar, @libpaths.join('" --libpath="'), $p6_mbc_path, $mbc) xx 2));
#!/bin/sh
%s --execname="$0" --libpath="%s" %s/%s -e '
say "=" x 96;

say "This is Rakudo Perl 6 running in the GNU debugger, which often allows the user to generate useful back-\ntraces to debug or report issues in Rakudo, the MoarVM backend or the currently running code.\n";

unless $*VM.config<ccdebugflags> { say "The currently used MoarVM backend is not compiled with debugging symbols, you might want to\nreconfigure and reinstall MoarVM with --debug enabled.\n" }

say "This Rakudo version is $*PERL.compiler.version() built on MoarVM version $*VM.version(),";
say "running on $*DISTRO.gist() / $*KERNEL.gist()\n";

say "Type `bt full` to generate a backtrace if applicable, type `q` to quite or `help` for help.";

say "-" x 96;'
gdb --quiet --ex=run --args %s --execname="$0" --libpath="%s" %s/%s "$@"
EOS
    $fh.close;
    chmod(0o755, $install_to);
}
elsif ($toolchain eq 'valgrind') {
    my $fh = open $install_to, :w;
    $fh.print(sprintf(q:to/EOS/, ($moar, @libpaths.join('" --libpath="'), $p6_mbc_path, $mbc) xx 2));
#!/bin/sh
%s --execname="$0" --libpath="%s" %s/%s -e '
say "=" x 96;

say "This is Rakudo Perl 6 running in valgrind, a tool for debugging and profiling programs.\nRunning a program in valgrind usually takes *a lot* more time than running it directly,\nso please be patient.";

say "This Rakudo version is $*PERL.compiler.version() built on MoarVM version $*VM.version(),";
say "running on $*DISTRO.gist() / $*KERNEL.gist()";

say "-" x 96;'
valgrind %s --execname="$0" --libpath="%s" %s/%s "$@"
EOS
    $fh.close;
    chmod(0o755, $install_to);
}
else {
    my $fh = open $install_to, :w;
    $fh.print(sprintf(q:to/EOS/, $moar, join('" --libpath="', @libpaths), $p6_mbc_path, $mbc));
#!/bin/sh
exec %s  --execname="$0" --libpath="%s" %s/%s "$@"
EOS
    $fh.close;
    chmod(0o755, $install_to);
}
