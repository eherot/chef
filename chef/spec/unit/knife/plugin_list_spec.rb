#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Chef::Knife::PluginList do
  before do
    @load_paths = %w{project_foo project_bar}.map{|libname| File.join(CHEF_SPEC_DATA,'knife_plugin_load_path',libname,'lib')}
    @knife = Chef::Knife::PluginList.new
  end

  it "finds all available plugins in $PROJECT/knife_plugins/*.rb in the load path" do
    @knife.stub!(:load_path).and_return(@load_paths)
    expected = %w{project_bar/knife_plugins/mycloud_server_create project_foo/knife_plugins/admin_add}
    @knife.available_plugins.should == expected
  end

  it "narrows down matches by a glob like 'ec2 *', 'ec2 server *' etc." do
    plugin_paths = %w{bell_and_whistles ec2_instance_data ec2_server_create ec2_server_list ec2_server_delete}
    plugin_paths.map! { |p| 'project_foo/knife_plugins/' + p }
    @knife.stub!(:load_path).and_return([File.join(CHEF_SPEC_DATA, 'knife_plugin_load_path', 'ec2', 'lib')])
    expected = %w{ec2_instance_data ec2_server_create ec2_server_delete ec2_server_list}.map do |p|
      'ec2/knife_plugins/' + p
    end
    @knife.find_plugins(['ec2', '*']).should == expected
    expected = %w{ec2_server_create ec2_server_delete ec2_server_list}.map do |p|
      'ec2/knife_plugins/' + p
    end
    @knife.find_plugins(['ec2', 'server', '*']).should == expected
  end

  it "groups plugins by installed/not-installed status" do
    pending
  end

  it "lists a user's home plugins" do
    pending
  end

  it "displays a description from the plugin if available" do
    pending
  end

  it "does not show the file if it's not a subclass of Chef::Knife" do
    pending
  end

  it "finds plugins in the user's $HOME/.chef/knife_plugins directory" do
    pending
  end

# and also.
# Chef::Knife
# - loads plugins
# - prints a warning and continues if the plugin dies on load
# - prints the backtrace from the error during load when given a --verbose or --backtrace flag (or log level debug?)
# Chef::Knife::PluginEnable
# - enables all plugins with --all
# - enables multiple plugins via glob
# - doesn't enable a plugin more than once

end