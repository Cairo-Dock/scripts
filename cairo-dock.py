'''apport package hook for cairo-dock

(c) 2009 Author: Matthieu Baerts <matttbe@gmail.com>
'''

from apport.hookutils import *
from os import path

def add_info(report):
    # Build System Environment
    report['system'] = "distro = Ubuntu, architecture = %s, kernel = %s" % (command_output(['uname','-m']), command_output(['uname','-r']))

    attach_related_packages(report, [
            "xserver-xorg",
            "libgl1-mesa-glx",
            "libdrm2",
            "xserver-xorg-video-intel",
            "xserver-xorg-video-ati"
            ])
            
    attach_file_if_exists(report, path.expanduser('~/.config/cairo-dock/current_theme/cairo-dock.conf'), 'CairoDockConf')
    # attach_hardware(report)
    
    # One-line description of display hardware
    report['PciDisplay'] = pci_devices(PCI_DISPLAY).split('\n')[0]

    # GLX
    report['glxinfo'] = command_output(['glxinfo'])

    # Compositing
    report['CompositingMetacity'] = command_output(['gconftool-2', '--get', '/apps/metacity/general/compositing_manager'])

    # WM
    report['WM'] = command_output(['gconftool-2', '--get', '/desktop/gnome/applications/window_manager/current'])


## DEBUGING ##
if __name__ == '__main__':
    report = {}
    add_info(report)
    for key in report:
        print '[%s]\n%s' % (key, report[key])
