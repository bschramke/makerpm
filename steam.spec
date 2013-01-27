Name: steam
Version: 1.0.0.22
Release: 1
Group: Applications/Games
BuildArch: noarch
Source: steam_1.0.0.22_i386.tar.gz
Summary: Steam Client
URL: http://www.steampowered.com/
License: EULA
BuildRoot: %{_tmppath}/%{name}-root
Vendor: Valve

Requires: Mesa-libGL1-32bit
Requires: gtk2-engine-oxygen-32bit
Requires: libXext6-32bit
Requires: libXfixes3-32bit
Requires: libXrender1-32bit
Requires: libatk-1_0-0-32bit
Requires: libgmodule-2_0-0-32bit
Requires: libgobject-2_0-0-32bit
Requires: libjpeg8-32bit
Requires: rpmlib(CompressedFileNames) <= 3.0.4-1
Requires: rpmlib(PayloadFilesHavePrefix) <= 4.0-1
Requires: rpmlib(PayloadIsLzma) <= 4.4.6-1
Requires: alsa-32bit >= 1.0.23
Requires: cups-libs-32bit >= 1.4.0
Requires: fontconfig-32bit >= 2.8.0
Requires: glibc-32bit >= 2.15
Requires: libSDL-1_2-0-32bit >= 1.2.10
Requires: libX11-6-32bit >= 1.4.99.1
Requires: libXi6-32bit >= 1.2.99.4
Requires: libXrandr2-32bit >= 1.2.99.3
Requires: libcairo2-32bit >= 1.6.0
Requires: libcurl4-32bit >= 7.16.2-1
Requires: libdbus-1-3-32bit >= 1.2.14
Requires: libfreetype6-32bit >= 2.3.9
Requires: libgcc47-32bit >= 4.1.1
Requires: libgcrypt11-32bit >= 1.4.5
Requires: libgdk_pixbuf-2_0-0-32bit >= 2.22.0
Requires: libglib-2_0-0-32bit >= 2.14.0
Requires: libgtk-2_0-0-32bit >= 2.24.0
Requires: libogg0-32bit >= 1.0
Requires: libopenal1-soft-32bit >= 1.13
Requires: libpango-1_0-0-32bit >= 1.22.0
Requires: libpixman-1-0-32bit >= 0.24.4
Requires: libpng >= 1.2.13
Requires: libpng12-0-32bit >= 1.2.13
Requires: libpulse0-32bit >= 0.99.1
Requires: libstdc++47-32bit >= 4.6
Requires: libtheora0-32bit >= 1.0
Requires: libvorbis0-32bit >= 1.1.2
Requires: mozilla-nspr-32bit >= 1.8.0.10
Requires: mozilla-nss-32bit >= 3.12.3
Requires: openal-soft >= 1.13
Requires: zlib-32bit >= 1.2.3.3

%description
Steam Client for GNU/Linux

%prep
%setup -q -c -n %{name}

%build
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/
cp -fpr %_builddir/steam/* %{buildroot}
rm -rf %{buildroot}/etc/apt/
chmod +x %{buildroot}/usr/bin/steam
chmod +x %{buildroot}/usr/bin/steamdeps

%install
find %{buildroot} -not -type d -printf "/%%P\n" | sed '/\/man\//s/$/\*/' > manifest

%files -f manifest
