/*
 * refresh_cd_on_resuming.c
 * 
 * Copyright 2013 Matthieu Baerts <matttbe@Matth>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * How to use it?
 *  * Install header files of gtk3 and dbus-glib
 *  * Launch:
 *   $ gcc refresh_cd_on_resuming.c -o refresh_cd_on_resuming `pkg-config --libs --cflags gtk+-3.0 dbus-glib-1`
 *   $ ./refresh_cd_on_resuming
 */


#include <stdio.h>
#include <stdlib.h>
#include <gtk/gtk.h>
#include <dbus/dbus-glib.h>

GMainLoop *s_pMainloop;

static void _quit (G_GNUC_UNUSED int signal)
{
	g_main_loop_quit (s_pMainloop);
	g_main_loop_unref (s_pMainloop);
}

static void _on_resuming (void)
{
	g_print ("Refresh dock after resuming\n");
	system ("dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.Reboot");
}

int main(int argc, char **argv)
{
	DBusGConnection *pConnection;
	DBusGProxy *pProxy;
	GError *error = NULL;

	g_type_init ();

	pConnection = dbus_g_bus_get (DBUS_BUS_SYSTEM, NULL);
	if (pConnection == NULL)
	{
		g_print ("Couldn't connect to system bus\n");
		return EXIT_FAILURE;
	}

	pProxy = dbus_g_proxy_new_for_name (pConnection,
		"org.freedesktop.UPower",
		"/org/freedesktop/UPower",
		"org.freedesktop.UPower");

	if (pProxy == NULL)
	{
		g_print ("UPower bus not available, can't connect to 'resuming' signal\n");
		return EXIT_FAILURE;
	}

	dbus_g_object_register_marshaller (
		g_cclosure_marshal_VOID__VOID,
		G_TYPE_NONE,
		G_TYPE_INVALID);

	dbus_g_proxy_add_signal (pProxy, "Resuming",
		G_TYPE_INVALID);
	dbus_g_proxy_connect_signal (pProxy, "Resuming",
		G_CALLBACK (_on_resuming), NULL, NULL);

	signal (SIGINT, _quit);
	signal (SIGTERM, _quit);

	s_pMainloop = g_main_loop_new (NULL, FALSE);
	g_print ("Start!\n");
	g_main_loop_run (s_pMainloop);

	g_print ("End!\n");

	dbus_g_proxy_disconnect_signal (pProxy, "Resuming",
			G_CALLBACK (_on_resuming), NULL);
	g_object_unref (pProxy);
	
	return EXIT_SUCCESS;
}

