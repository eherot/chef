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

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


require 'rubygems'
require 'extlib'
require 'chef/backports'
require 'chef/exceptions'
require 'chef/log'
require 'chef/config'
require 'chef/provider'
require 'chef/resource'
require 'chef/mixin'
require 'chef/runner'
require 'chef/application'
require 'chef/application/solo'
require 'chef/application/client'
require 'chef/util/fileedit'
require 'chef/util/file_edit'

require 'chef/recipe'

# hrmm...
require 'chef/application/knife'
module Chef
  VERSION = '0.8.0'
end

