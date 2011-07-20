Summary:   Text search application
Name:      glark
Version:   1.8.2
Release:   1
Epoch:     0
License:   LGPL
Group:     Applications/Text
URL:       http://glark.sourceforge.net/
Source:    http://prdownloads.sourceforge.net/glark/glark-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildArch: noarch
Packager:  Jeff Pace (jpace@incava.org)
Vendor:    incava.org
Requires:  ruby >= 1.6.0

%description
Similar to grep, glark searches files, automatically excluding binary
file. It uses Perl compatible regular expressions, and can highlight
matches, display context around matches, combine regular expressions
into logical expressions using "and", "or", and "xor". Regular
expressions can be negated.

%prep
%setup -q

%build

%install
[ "$RPM_BUILD_ROOT" -a "$RPM_BUILD_ROOT" != / ] && rm -rf "$RPM_BUILD_ROOT"

%makeinstall

%clean
[ "$RPM_BUILD_ROOT" -a "$RPM_BUILD_ROOT" != / ] && rm -rf "$RPM_BUILD_ROOT"

%files
%defattr(-,root,root,-)
%{_bindir}/glark
%{_mandir}/man1/glark.1*
%attr(0755,root,root) %{_datadir}/glark/*.rb

%changelog
* Fri Oct 24 2008 Jeff Pace <jpace@incava.org> 1.8.2-1
- Fixed error message for the usage of a single hyphen as an option.

* Tue Aug 29 2006 Jeff Pace <jpace@incava.org> 1.7.11-1
- Fixed stack overrun with very large search files.
- Reorganized files.

* Tue Aug 29 2006 Jeff Pace <jpace@incava.org> 1.7.10-1
- Added support for --with/without-fullname/basename.
- Fixed bug handling --after=N and --before=N for non-percentage arguments.

* Thu Mar 30 2006 Jeff Pace <jpace@incava.org> 1.7.9-1
- Fixed bug in --and option, which was getting the closest match within the
maximum distance.
- More refactoring and tests.

* Sat Mar 18 2006 Jeff Pace <jpace@incava.org> 1.7.8-1
- Fixed bug with --invert-match (-v) option.
- Added check for cycles, for links that result in recursive file hierarchies.
- Significant refactoring.

* Wed Feb 22 2006 Jeff Pace <jpace@incava.org> 1.7.7-1
- Fixed --label option to take any string.
- Fixed warnings for unknown options.

* Fri Jan 27 2006 Jeff Pace <jpace@incava.org> 1.7.6-1
- Fixed exit status to match that of grep.
- Extended -H option so that the file name is always printed, even if only one
file is searched.

* Sat Aug 27 2005 Jeff Pace <jpace@incava.org> 1.7.5-1
- Added infix notation.

* Tue Aug  9 2005 Jeff Pace <jpace@incava.org> 1.7.4-1
- Fixed bug in --no-filter.
- Added and refined documentation.
- Added --size-limit option.

* Tue May 31 2005 Jeff Pace <jpace@incava.org> 1.7.3-1
- Added -- as the explicit end of options.
- Bug in --binary-file mode fixed.
- Line number colors disabled by default. 

* Thu Dec 23 2004 Jeff Pace <jpace@incava.org> 1.7.2-1
- Fixed problem with line number and start of text.
- Fixed bug in --binary-file mode.
- Disabled line number colors, by default.

* Thu Nov  4 2004 Jeff Pace <jpace@incava.org> 1.7.1-1
- Added multiple colors for highlighting different regular expressions.
- Added HTML output format.
- Output is now unbuffered, that is, is written before end of file is reached.

* Tue Apr 20 2004 Jeff Pace <jpace@incava.org> 1.7.0-1
- Added --config option, for dumping the current configuration.
- Added diff-line break ("---") as optional break between context blocks.
- Added feature to split argument by path separator, for searching recursively
along a path.
- Extended "--and NUM" to "--and=NUM" format.
- Fixed --exclude-matching option.
- Fixed highlighted strings, so that the ANSI codes are not matched with regexps.
- Refined --help output into more logical sections.
- Removed --no-line-regexp and --no-word options, which are not necessary.

* Thu Apr  8 2004 Jeff Pace <jpace@incava.org> 1.7.0-1
- Added --fullname/--path and --basename/--name options.
- Added --xor option.
- Cleanup of RPM spec file and Makefile.

* Tue Apr  6 2004 Jose Pedro Oliveira <jpo@di.uminho.pt> 0:1.6.8-2
- removal of several rpmlint warnings/errors

* Fri Mar 05 2004 Jeff Pace
- Implemented support of '!/expression/'.
