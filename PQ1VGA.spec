#
# spec file for package PQ1VGA
#
# Copyright (c) 2013 Björn Schramke, Brandenburg an der Havel, Germany.
# Copyright (c) 2012 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

Name:           PQ1VGA
#BuildRequires:  unzip
BuildRequires:  update-desktop-files
Requires:       scummvm
Requires:       timidity
Version:        1.0
Release:        0
Summary:        Police Quest: In Pursuit of the Death Angel (Adventure Game)
License:        proprietary
Group:          Amusements/Games/Other
Source:         %name.tar.gz
Source1:        %name
Source2:        %name.desktop
Source3:        PQ1.png
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Police Quest is a series of police simulation video games produced and published by Sierra On-Line between 1987 and 1998.

%prep
%setup -q -c -n %{name}
#unzip $RPM_SOURCE_DIR/%name.tar.gz

%build

%install
mkdir -p $RPM_BUILD_ROOT/usr/games
mkdir -p $RPM_BUILD_ROOT/usr/share/games/%name
mkdir -p $RPM_BUILD_ROOT/usr/share/doc/packages/%name
#install -m 644 sky-floppy/sky.dnr $RPM_BUILD_ROOT/usr/share/games/BASS
#install -m 644 sky-floppy/sky.dsk $RPM_BUILD_ROOT/usr/share/games/BASS
#install -m 644 $RPM_SOURCE_DIR/SKY.CPT $RPM_BUILD_ROOT/usr/share/games/BASS
#install -m 644 $RPM_SOURCE_DIR/info $RPM_BUILD_ROOT/usr/share/games/BASS
#install -m 644 sky-floppy/readme.txt $RPM_BUILD_ROOT/usr/share/doc/packages/BASS
install -m 755 $RPM_SOURCE_DIR/PQ1VGA $RPM_BUILD_ROOT/usr/games
mkdir -p $RPM_BUILD_ROOT/usr/share/pixmaps/
install -m 644 $RPM_SOURCE_DIR/PQ1.png $RPM_BUILD_ROOT/usr/share/pixmaps
%suse_update_desktop_file -i %name Game X-SuSE-AdventureGame
rm -f $RPM_BUILD_ROOT/usr/share/pixmaps/PQ1

%files
%defattr(-,root,root)
%doc /usr/share/doc/packages/%name/
/usr/games/%name
/usr/share/games/%name/
/usr/share/applications/%name.desktop
/usr/share/pixmaps/PQ1.png

%changelog
