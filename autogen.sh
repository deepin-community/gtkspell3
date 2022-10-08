#!/bin/sh
# Run this to generate all the initial makefiles, etc.

set -o errexit

srcdir="$(dirname "$(readlink -f "$0")")"

(test -f "$srcdir"/configure.ac) || {
  echo -n "**Error**: Directory "\`$srcdir\'" does not look like the"
  echo " top-level package directory"
  echo
  exit 1
}

(intltoolize --version) < /dev/null > /dev/null 2>&1 || {
  echo "**Error**: You must have \`intltool' installed."
  echo "You can get it from:"
  echo "  https://launchpad.net/intltool"
  echo
  exit 1
}

(libtool --version) < /dev/null > /dev/null 2>&1 || {
  echo "**Error**: You must have \`libtool' installed."
  echo "You can get it from: ftp://ftp.gnu.org/pub/gnu/"
  echo
  exit 1
}

(autoreconf --version) < /dev/null > /dev/null 2>&1 || {
  echo "**Error**: You must have \`autoconf' installed."
  echo "Download the appropriate package for your distribution,"
  echo "or get the source tarball at ftp://ftp.gnu.org/pub/gnu/"
  echo
  exit 1
}

(aclocal --version) < /dev/null > /dev/null 2>&1 || {
  echo "**Error**: You must have \`automake' installed."
  echo "Download the appropriate package for your distribution,"
  echo "or get the source tarball at ftp://ftp.gnu.org/pub/gnu/"
  echo
  exit 1
}

(stat "$(aclocal --print-ac-dir)/ax_cxx_compile_stdcxx_11.m4") < /dev/null > /dev/null 2>&1 || {
  echo "**Error**: You must have the \`ax_cxx_compile_stdcxx_11.m4' macro installed-"
  echo "Download the appropriate package for your distribution,"
  echo "or get it from http://mirror.switch.ch/ftp/mirror/gnu/autoconf-archive/"
  echo
  exit 1
}


(
  cd "$srcdir"
  mkdir -p build
  echo "Running intltoolize..."
  intltoolize --force --copy --automake || exit 1
)


echo "Running gtkdocize..."
if ! command -v gtkdocize >/dev/null; then
  echo "gtkdocize not found, skipping"
else
  gtkdocize --srcdir "$srcdir" || exit 1
fi


echo "Running autoreconf..."
autoreconf -fiv "$srcdir" || exit 1


if test x$NOCONFIGURE = x; then
  echo Running $srcdir/configure "$@" ...
  "$srcdir"/configure "$@" \
  && echo Now type \`make\' to compile. || exit 1
else
  echo Skipping configure process.
fi
