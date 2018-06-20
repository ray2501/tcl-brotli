#!/usr/bin/tclsh

set arch "x86_64"
set base "tcl-brotli-1.0"

file mkdir $base
cd $base
file copy ../brotli.tcl .
cd ..

set var [list tar czvf $base.tar.gz $base]
exec >@stdout 2>@stderr {*}$var

if {[file exists build]} {
    file delete -force build
}

file mkdir build/BUILD build/RPMS build/SOURCES build/SPECS build/SRPMS
file copy -force $base.tar.gz build/SOURCES

set buildit [list rpmbuild --target $arch --define "_topdir [pwd]/build" -bb tcl-brotli.spec]
exec >@stdout 2>@stderr {*}$buildit

# Remove our source code
file delete -force $base
file delete $base.tar.gz
