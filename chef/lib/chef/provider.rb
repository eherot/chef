#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Copyright:: Copyright (c) 2008, 2009 Opscode, Inc.
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

require 'chef/mixin/from_file'
require 'chef/mixin/convert_to_class_name'
#require 'chef/mixin/recipe_definition_dsl_core'

require 'chef/provider/base.rb'

require 'chef/provider/breakpoint.rb'
require 'chef/provider/cron.rb'
require 'chef/provider/deploy.rb'
require 'chef/provider/deploy/revision.rb'
require 'chef/provider/deploy/timestamped.rb'
require 'chef/provider/directory.rb'
require 'chef/provider/erl_call.rb'
require 'chef/provider/execute.rb'
require 'chef/provider/file.rb'
require 'chef/provider/git.rb'
require 'chef/provider/group.rb'
require 'chef/provider/group/dscl.rb'
require 'chef/provider/group/gpasswd.rb'
require 'chef/provider/group/groupadd.rb'
require 'chef/provider/group/pw.rb'
require 'chef/provider/group/usermod.rb'
require 'chef/provider/http_request.rb'
require 'chef/provider/ifconfig.rb'
require 'chef/provider/link.rb'
require 'chef/provider/mdadm.rb'
require 'chef/provider/mount.rb'
require 'chef/provider/mount/mount.rb'
require 'chef/provider/package.rb'
require 'chef/provider/package/apt.rb'
require 'chef/provider/package/dpkg.rb'
require 'chef/provider/package/easy_install.rb'
require 'chef/provider/package/freebsd.rb'
require 'chef/provider/package/macports.rb'
require 'chef/provider/package/portage.rb'
require 'chef/provider/package/rpm.rb'
require 'chef/provider/package/rubygems.rb'
require 'chef/provider/package/yum.rb'
require 'chef/provider/package/zypper.rb'
require 'chef/provider/remote_directory.rb'
require 'chef/provider/remote_file.rb'
require 'chef/provider/route.rb'
require 'chef/provider/ruby_block.rb'
require 'chef/provider/script.rb'
require 'chef/provider/service.rb'
require 'chef/provider/service/debian.rb'
require 'chef/provider/service/freebsd.rb'
require 'chef/provider/service/gentoo.rb'
require 'chef/provider/service/init.rb'
require 'chef/provider/service/redhat.rb'
require 'chef/provider/service/simple.rb'
require 'chef/provider/subversion.rb'
require 'chef/provider/template.rb'
require 'chef/provider/user.rb'
require 'chef/provider/user/dscl.rb'
require 'chef/provider/user/pw.rb'
require 'chef/provider/user/useradd.rb'
