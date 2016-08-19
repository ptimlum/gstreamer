# 

default['gstreamer']['install_type'] = 	'source'
default['gstreamer']['src_url'] =       'https://gstreamer.freedesktop.org/src'
default['gstreamer']['version'] =       '1.8.1'

# use the package name unless a relative path from the src_url is specified
default['gstreamer']['relative_path'] = false

# older archives may be in tar.gz and tar.bz2
default['gstreamer']['bundle_type'] =   'tar.xz'
default['gstreamer']['download_dir'] =  Chef::Config[:file_cache_path]

default['gstreamer']['depends'] = [
    'glib2-devel',
    'zlib-devel',
    'gettext-devel',
    'yasm-devel',
    'nasm',
    'gtk-doc'
  ]

default['gstreamer']['automake']['version'] = '1.15'
default['gstreamer']['automake']['url'] = "http://ftp.gnu.org/gnu/automake/automake-#{node.gstreamer.automake.version}.tar.gz"

# assumes download path to be #{src_url}/#{package_name}/#{package_name}-#{version}.#{bundle_type}
default['gstreamer']['packages'] = {
  'automake' => {
    'version' => node['gstreamer']['automake']['version'],
    'url' => node['gstreamer']['automake']['url'],
    'autoconf_opts' => [],
    'install' => true
  },
  'gstreamer' => {
    'install' => true
  },
  'gst-plugins-base' => {
    'install' => true
  },
  'gst-libav' => {
    'install' => false
  },
  'gst-plugins-good' => {
    'install' => true
  },
  'gst-plugins-bad' => {
    'install' => false
  },
  'gst-plugins-ugly' => {
    'install' => false
  }
}

# install prefix
include_attribute 'ark::default'
default['gstreamer']['prefix'] = node['ark']['prefix_root']
default['gstreamer']['configure_opts'] = {
    'prefix' => node['gstreamer']['prefix'],
    'with-pkg-config-path' => "#{node['gstreamer']['prefix']}/lib/pkgconfig",
  }

if node['gstreamer']['packages']['automake']['install']
 default['gstreamer']['configure_opts'] = 
   node['gstreamer']['configure_opts'].merge( 
    'with-automake' => "#{node['ark']['prefix_root']}/bin/automake"
   )
end

# build the autoconf array
autoconf_opts = []
node['gstreamer']['configure_opts'].each do |opt_key,opt_value|
  autoconf_opts << "--#{opt_key}=#{opt_value}"
end

# fill in the blanks
node['gstreamer']['packages'].each do |gs_package,package_opts|
  unless package_opts.has_key?('version')
    default['gstreamer']['packages'][gs_package]['version'] = node['gstreamer']['version']
  end

  unless package_opts.has_key?('autoconf_opts')
    default['gstreamer']['packages'][gs_package]['autoconf_opts'] = autoconf_opts
  end

  unless package_opts.has_key?('url')
    default['gstreamer']['packages'][gs_package]['url'] = File.join( 
      node['gstreamer']['src_url'], 
      node['gstreamer']['relative_path'] ? node['gstreamer']['relative_path'] : gs_package, 
      "#{gs_package}-#{node['gstreamer']['version']}.#{node['gstreamer']['bundle_type']}" 
    )
  end
end

