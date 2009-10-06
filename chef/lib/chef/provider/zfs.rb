#
# Author:: Sig Lange (<sig.lange@gmail.com>)
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
require 'chef/mixin/command'
require 'chef/log'
require 'chef/file_cache'
require 'chef/resource/remote_file'
require 'chef/platform'

class Chef
  class Provider
    class Zfs < Chef::Provider
      
      include Chef::Mixin::Command
      
      def initialize(node, new_resource)
        super(node, new_resource)
      end

      def action_create
        case @exists
        when false
          create_zfs
          Chef::Log.info("Created #{@new_resource}")
          @new_resource.updated = true
        end
      end

      def action_destroy
        if @exists
          destroy_zfs
          @new_resource.updated = true
          Chef::Log.info("Destroyed #{@new_resource}")
        end
      end

      
    end
  end
end
