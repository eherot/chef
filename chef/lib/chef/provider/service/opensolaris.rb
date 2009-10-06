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
require 'chef/provider/service'
require 'chef/provider/service/init'
require 'chef/mixin/command'

class Chef
  class Provider
    class Service
      class Opensolaris < Chef::Provider::Service::Init
        def load_current_resource
          super

          status = popen4("svcs -H #{@current_resource.service_name}") do |pid, stdin, stdout, stderr|
            r = /^disabled /
	   # STATE can be: disabled legacy_run maintenance offline online
            stdout.each_line do |line|
              if r.match(line)
                @current_resource.enabled false
                break
              else
                @current_resource.enabled true
              end
            end
          end

          @current_resource        
        end

        def enable_service()
          run_command(:command => "svcadm enable #{@new_resource.service_name}")
        end

        def disable_service()
          run_command(:command => "svcadm disable #{@new_resource.service_name}")
        end
        
      end
    end
  end
end
