
# gstreamer cookbook

## Overview
This cookbook is basically an [ark cookbook](https://supermarket.chef.io/cookbooks/ark) wapper that builds and installs [gstreamer](https://gstreamer.freedesktop.org/) and it's plugins/modules from the [source tarballs](https://gstreamer.freedesktop.org/src/).

My basic objective is to be able to able to listen to mp3's on my primary development machines (CentOS/Fedora) using the Linux media players (rythmbox, banshee, etc ...) without having to add additional repos. 

## Requirements
### Platforms
- RHEL/CentOS
- Fedora

### Chef
- Chef 11+

### Dependency Cookbooks
- build-essential
- ark

## Attributes
Customize the attributes to suit site specific conventions and defaults.
* `node['gstreamer']['install_type']` - *source* only for now 
* `node['gstreamer']['src_url']` - default base url of the source tarballs _https://gstreamer.freedesktop.org/src_
* `node['gstreamer']['bundle_type']` - *tar.xz* default, earlier versions included bundles for both *tar.gz* and *tar.bz2*
* `node['gstreamer']['prefix']` - install prefix, default is */usr/local* so the library files would be installed into */usr/local/lib/gstreamer-1.0* this would also require application alter their PKG_CONFIG_PATH to include */usr/local/lib/pkgconfig*. (setting this to */usr* would be the lazy way for application to discover the built libraries)
* `node['gstreamer']['configure_opts']` - these are the commandline option overrides as a hash table to be passed to autoconf/configure, with *prefix* and *with-pkg-config-path* using the `node['gstreamer']['prefix']` attribute value/
* `node['gstreamer']['relative_path]` - this to download from #{src_url}/#{relative_path}/#{package_name}-#{version}.#{bundle_type} (since I'm lazy, I predownload the source tarball to a single directory and set *relative_path* to ''. This is so one might specify local download as something src_url = 'file///tmp/mydownloads')
* `node['gstreamer']['depends']` - extra (yum) packages required for building.
* `node['gstreamer']['packages']` - hash of modules with the package name matching the tarball, default behavior is to download #{src_url}/#{package_name}/#{package_name}-#{version}.#{bundle_type} . This was created to expandable to so that one might build and install other components not listed in the default attributes. (mp3's playback apparently additionally requires gst-plugins-ugly, gst-plugins-bag and gst-libav)
.* `install` - true/false, default is the minimal confige of gstreamer, gst-plugins-base, gst-plugins-good (these are available from the base distros repos as yum/rpm packages)


## Tested
Fedora 17/21
Centos 7

## Does not work out of the box
The default setting for this cookbook is no better (maybe worse) than installing gstreamer from the centos yum repos. The default settings will only build and deploy gstreamer, and the base + good plugins, which are already available as pre-compiled rpm packages.


This is a snipett of my environment JSON which does what needed for my objective:
``` 
    "gstreamer": {
      "version": "1.8.2",
      "packages": {
        "gst-libav": {
          "install": true
        },
        "gst-plugins-ugly": {
          "install": true
        }
      },
      "configure_opts": {
        "with-pkg-config-path": "/usr/lib64/pkgconfig",
        "libdir": "/usr/lib64"
      }
    },
```

The ark LWRP and most any _make install_ will install into _/usr/local/lib/pkgconfig_ but RHEL variants will only search *pgkconfig* the paths of /usr/lib64/pgkconfig and /usr/share/pkconfig without any overrides from *PKG_CONFIG_PATH*. The above configuration will dump the pgkconfig files into */usr/lib64/pgkconfig* and will re-link the runtime libraries from /usr/lib64 that would normally be installed from the yum/package installs.

If everything worked out
```
yum install bansheee
```

should all one to listen to your personal mp3 library without adding additional repository sources ... which is all that I was after.

(... and I just like to be able to build things from source even if I'm not actively modifying the code)

## License and Authors

Author:: Tim Lum (<YOUR_EMAIL>)

    Copyright (C) 2016

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
