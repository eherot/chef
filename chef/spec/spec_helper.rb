#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

# Abuse ruby's constant lookup to avoid undefined constant errors
module Shef
  JUST_TESTING_MOVE_ALONG = true unless defined? JUST_TESTING_MOVE_ALONG
  IRB = nil unless defined? IRB
end

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "chef-server", "lib"))

require 'chef'
require File.join(File.dirname(__FILE__), "/../lib/chef/util/file_edit")

chef_lib_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
Dir[
  File.expand_path(
    File.join(
      chef_lib_path, 'chef', '**', '*.rb'
    )
  )
].sort.each do |lib|
  lib_short_path = lib.match("^#{chef_lib_path}#{File::SEPARATOR}(.+)$")[1]
  require lib_short_path
end
Dir[File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')].sort.each { |lib| require lib }

Chef::Config[:log_level] = :fatal
Chef::Config[:cache_type] = "Memory"
Chef::Config[:cache_options] = { } 

Chef::Log.level(Chef::Config.log_level)
Chef::Config.solo(false)

Chef::Log.logger = Logger.new(StringIO.new)

def redefine_argv(value)
  Object.send(:remove_const, :ARGV)
  Object.send(:const_set, :ARGV, value)
end

def with_argv(*argv)
  original_argv = ARGV
  redefine_argv(argv.flatten)
  begin
    yield
  ensure
    redefine_argv(original_argv)
  end
end

