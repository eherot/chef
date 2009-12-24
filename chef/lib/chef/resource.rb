#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# Copyright:: Copyright (c) 2009 Daniel DeLeo
#
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

require 'chef/mixin/params_validate'
require 'chef/mixin/check_helper'
require 'chef/mixin/language'
require 'chef/mixin/convert_to_class_name'
require 'chef/resource_collection'
require 'chef/node'

require 'chef/resource/base'

require 'chef/resource/package.rb'
require 'chef/resource/apt_package.rb'
require 'chef/resource/bash.rb'
require 'chef/resource/breakpoint.rb'
require 'chef/resource/cron.rb'
require 'chef/resource/csh.rb'
require 'chef/resource/deploy.rb'
require 'chef/resource/deploy_revision.rb'
require 'chef/resource/directory.rb'
require 'chef/resource/dpkg_package.rb'
require 'chef/resource/easy_install_package.rb'
require 'chef/resource/erl_call.rb'
require 'chef/resource/execute.rb'
require 'chef/resource/file.rb'
require 'chef/resource/gem_package.rb'
require 'chef/resource/git.rb'
require 'chef/resource/group.rb'
require 'chef/resource/http_request.rb'
require 'chef/resource/ifconfig.rb'
require 'chef/resource/link.rb'
require 'chef/resource/macports_package.rb'
require 'chef/resource/mdadm.rb'
require 'chef/resource/mount.rb'
require 'chef/resource/perl.rb'
require 'chef/resource/portage_package.rb'
require 'chef/resource/python.rb'
require 'chef/resource/remote_directory.rb'
require 'chef/resource/remote_file.rb'
require 'chef/resource/route.rb'
require 'chef/resource/ruby.rb'
require 'chef/resource/ruby_block.rb'
require 'chef/resource/scm.rb'
require 'chef/resource/script.rb'
require 'chef/resource/service.rb'
require 'chef/resource/subversion.rb'
require 'chef/resource/template.rb'
require 'chef/resource/timestamped_deploy.rb'
require 'chef/resource/user.rb'
