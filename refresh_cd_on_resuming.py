#!/usr/bin/python
# -*- coding: utf-8 -*-
#
#  refresh_cd_on_resuming.py
#  
#  Copyright 2013 Matthieu Baerts <mbaerts@Matth>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

#
#  Launch it at startup as a daemon
#   Info: http://glx-dock.org/ww_page.php?p=Recurrents%20problems&lang=en
#         => Icons are corrupted after wake-up from suspend
#

from __future__ import print_function

import os
import signal

import gobject
import dbus
from dbus.mainloop.glib import DBusGMainLoop

loop = gobject.MainLoop ()

def on_quit (signal, frame):
	global loop
	print ("on_quit")
	loop.quit()

def restart_dock ():
	print ("restart dock")
	bus = dbus.SessionBus ()
	cd_dbus_object = bus.get_object('org.cairodock.CairoDock', '/org/cairodock/CairoDock')
	cd_dbus_iface = dbus.Interface(cd_dbus_object, 'org.cairodock.CairoDock')
	cd_dbus_iface.Reboot ()

def on_received_signal_login1 (bSuspend): # false <=> resuming
	print ("on_received_signal:", bSuspend)
	if (not bSuspend):
		restart_dock ()

def on_received_signal (*args): # old deprecated UPower signal
	print ("on_received_signal")
	restart_dock ()

def main ():
	# Setup message bus.
	bus = dbus.SystemBus (mainloop=DBusGMainLoop ())
	if bus.name_has_owner('org.freedesktop.login1'):
		print ("connecting to login1")
		bus_object = bus.get_object ('org.freedesktop.login1', '/org/freedesktop/login1')
		# signals
		bus_object.connect_to_signal ('PrepareForSleep', on_received_signal_login1, dbus_interface='org.freedesktop.login1.Manager')
	else:
		print ("connecting to UPower")
		bus_object = bus.get_object ('org.freedesktop.UPower', '/org/freedesktop/UPower')
		# signals
		bus_object.connect_to_signal ('Resuming', on_received_signal, dbus_interface='org.freedesktop.UPower') 

	# Ctrl+C + sigterm
	signal.signal(signal.SIGINT, on_quit)
	signal.signal(signal.SIGTERM, on_quit)

	# Wait until we receive the signal
	global loop
	loop.run ()

	return 0

if __name__ == '__main__':
	main ()

