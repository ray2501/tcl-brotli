#
# spec file for package tcl-brotli
#

%define packagename brotli

Name:           tcl-brotli
Version:        1.0
Release:        0
License:        BSD-3-Clause
Summary:        Brotli (de)compressor objects for Tcl
Url:            https://wiki.tcl.tk/48939
Group:          Development/Libraries/Tcl
Source:         %{name}-%{version}.tar.gz
BuildRequires:  tcl >= 8.4
BuildRequires:  gcc
BuildRequires:  tcllib
BuildRequires:  critcl >= 3.1
BuildRequires:  critcl-devel >= 3.1
BuildRequires:  libbrotli-devel
BuildRequires:  libbrotlicommon1
BuildRequires:  libbrotlidec1
BuildRequires:  libbrotlienc1
Requires:       tcl >= 8.4
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
It is a small wrapper for the Brotli compression format.

%prep
%setup -q -n %{name}-%{version}

%build
critcl -pkg brotli.tcl

%install
mkdir -p %buildroot%tcl_archdir/%{packagename}%{version}
cp lib/brotli/critcl-rt.tcl %buildroot%tcl_archdir/%{packagename}%{version}
cp lib/brotli/pkgIndex.tcl %buildroot%tcl_archdir/%{packagename}%{version}
cp -r lib/brotli/linux-x86_64 %buildroot%tcl_archdir/%{packagename}%{version}

%files
%defattr(-,root,root)
%{tcl_archdir}/%{packagename}%{version}

