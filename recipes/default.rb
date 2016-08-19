#
# Cookbook Name:: gstreamer
# Recipe:: default
#
# Copyright (C) 2016 Tim Lum
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

include_recipe 'build-essential'

# install addition build tools and libraries
node['gstreamer']['depends'].each do |depend_package|
  package depend_package
end

# build the autoconf array
autoconf_opts = []
node['gstreamer']['configure_opts'].each do |opt_key,opt_value|
  autoconf_opts << "--#{opt_key}=#{opt_value}"
end

# install each component from source
node['gstreamer']['packages'].each do |gs_package,package_opts|
  ark gs_package do
    version package_opts['version']
    url package_opts['url']
    autoconf_opts package_opts['autoconf_opts']
    environment ({
      'PATH' => 		"#{node['ark']['prefix_root']}/bin:#{ENV['PATH']}",
      'PKG_CONFIG_PATH' => 	node['gstreamer']['configure_opts']['with-pkg-config-path']
    })
    action :install_with_make
    only_if{ package_opts['install'] }
  end
end
