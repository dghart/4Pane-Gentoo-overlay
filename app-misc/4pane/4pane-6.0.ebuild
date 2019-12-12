# Copyright 2007-2019 David Hart
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="A four-pane, detailed-list file manager"
HOMEPAGE="http://www.4pane.co.uk/"
SRC_URI="http://www.4pane.co.uk/gentoo/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="debug"
DEPEND=">=x11-libs/wxGTK-3.0.0
        app-arch/xz-utils"
FEATURES="sign"

# The '--disable-desktop' et al stop the makefile trying to do these things; so hacking away at it isn't necessary
src_compile() {
		econf \
				--prefix=/usr --enable-symlink=uninstall_only --disable-desktop --disable-locale \
				--disable-install_rc --disable-install_docs \
				$(use_enable debug) \
				|| die "econf failed"

		emake || die "emake failed"
}

src_install() {
		emake DESTDIR="${D}" install || die "emake install failed"

		# Make a symlink called 4pane, in case someone believes the package-name
		dosym /usr/bin/4Pane /usr/bin/4pane

# ***** In the following, I'm using /usr/share/4Pane/, not /usr/share/4pane-${version}/
# ***** as the program looks for /usr/share/4Pane/rc etc
# ***** If you change this, symlinks will be needed
# This will put all the rc files into /usr/share/4pane/rc
		insinto /usr/share/4Pane/rc
		doins rc/*
# Similarly for bitmaps
		insinto /usr/share/4Pane/bitmaps
		doins bitmaps/*
		insinto /usr/share/4Pane/bitmaps/include
		doins bitmaps/include/*
# This will put all the doc files into /usr/share/doc/4pane/
		insinto /usr/share/doc/4pane
		doins doc/*
# And any translations. 
		# The tarball has these in locale/<lang>/LC_MESSAGES/4Pane.mo
		# domo wants <lang>.mo
		for lang in locale/* ; do
		  if [[ -e "$lang/LC_MESSAGES/4Pane.mo" ]] ; then
		    cp -a "$lang/LC_MESSAGES/4Pane.mo" "${lang##*/}.mo"
		  fi
		done
		domo *.mo


# ***** If you change the doc dir to /usr/share/doc/${P}, you'll need this symlink
#		dosym /usr/share/doc/${P} /usr/share/doc/4pane

		dodoc LICENCE README
		doman 4Pane.1

# It would be nice if make_desktop_entry inserted the shortcut onto the user's desktop
# but it doesn't: it puts it into /usr/share/applications/ :(
		make_desktop_entry 4Pane "4Pane" /usr/share/4Pane/bitmaps/4PaneIcon48.png
}

pkg_postinst() {
# See if we can work out who the user will be (remember it'll be root who's installing)
# If so, provide a desktop shortcut in his name
		HOMEDIR=/home/$USERNAME
		if test -d $HOMEDIR/Desktop
		then
			cp -u /usr/share/4Pane/rc/4Pane.desktop $HOMEDIR/Desktop/4Pane.desktop
			chown --reference=$HOMEDIR/Desktop $HOMEDIR/Desktop/4Pane.desktop
			chmod 0755 $HOMEDIR/Desktop/4Pane.desktop
		fi
}

pkg_postrm() {
# Remove the desktop shortcut
		rm -f /home/$USERNAME/Desktop/4Pane.desktop
}

