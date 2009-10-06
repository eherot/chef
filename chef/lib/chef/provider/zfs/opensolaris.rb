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
require 'chef/log'
require 'chef/mixin/command'

class Chef
  class Provider
    class Zfs
      class Opensolaris < Chef::Provider::Zfs

	attr_accessor :exists

        include Chef::Mixin::Command

        def initialize(node, new_resource)
          super(node, new_resource)

          @real_device = nil
        end

        def load_current_resource
          @current_resource = Chef::Resource::Zfs.new(@new_resource.name)

          Chef::Log.debug("Checking for zfs pool #{@current_resource.name}")

          # Check to see if the zfs line exists
          exists = false
          popen4("zfs list") do |pid, stdin, stdout, stderr|
            stdout.each do |line|
              case line
              when /^#{@current_resource.name}/
                exists = true
                Chef::Log.debug("found zfs resource #{@current_resource.name}")
              end
            end
          end
          Chef::Log.debug("zfs resource #{@current_resource.name} exists = #{exists}")
          @current_resource.exists(exists)

        end

	def create_zfs

		options = []
		# all options quota exec reservation mountpoint casesensitive 
		%w{ mountpoint quota }.each do  |o|
			o_symbol = o.to_sym
			if @new_resource.send(o_symbol)
                		Chef::Log.debug(" zfs option #{o} = #{@new_resource.send(o_symbol)}")
				options << "-o %s=%s" % [ o, @new_resource.send(o_symbol) ]
			end
		end

		run_command( :command => "zfs create #{options.join(" ")} #{@new_resource.name}", :ignore_failure => true)
	end

	def destroy_zfs
		run_command( :command => "zfs destroy #{@new_resource.name}", :ignore_failure => true)
	end

	def action_create
	  if ! @current_resource.exists
		  Chef::Log.info("created zfs #{@new_resource.name}")
		  create_zfs
	  end
	end

	def action_destroy
	  if @current_resource.exists
		  Chef::Log.info("destroyed zfs #{@new_resource.name}")
		  destroy_zfs
	  end
	end
      end
    end
  end
end
