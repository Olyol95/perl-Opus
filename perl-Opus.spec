Name:           perl-Opus
Version:        1.0.0
Release:        1
Summary:        Perl bindings for libopus

License:        GPLv3
URL:            https://oliver.youle.io/
Source0:        %{name}-%{version}-%{release}.tar.gz
BuildArch:      x86_64
Distribution:   fedora-31-x86_64, epel-8-x86_64

Requires: opus

BuildRequires: gcc perl opus-devel
BuildRequires: perl(XSLoader) perl(Carp)
BuildRequires: perl(ExtUtils::MakeMaker) perl(Test::More)
BuildRequires: perl(Test::Exception) perl(Test::MemoryGrowth)

Provides: perl(Opus::Encoder) perl(Opus::Decoder)

%{?perl_default_filter}

%description
Perl bindings for libopus

%prep
%autosetup

%build
perl Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
make pure_install DESTDIR=%{buildroot}
find %{buildroot} -type f -name .packlist -exec rm -f {} ';'
find %{buildroot} -type f -name '*.bs' -size 0 -exec rm -f {} ';'
%{_fixperms} %{buildroot}

%check
make test

%files
%{perl_vendorarch}/Opus.pm
%{perl_vendorarch}/auto/Opus/
%{perl_vendorarch}/Opus/
%{_mandir}/man3/Opus.3pm.gz
%{_mandir}/man3/Opus::Decoder.3pm.gz
%{_mandir}/man3/Opus::Encoder.3pm.gz

%changelog
* Sun Oct 25 2020 Oliver Youle <youle.oliver@gmail.com> - 1.0.0-1
- Initial build
