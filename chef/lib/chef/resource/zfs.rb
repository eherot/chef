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
require 'chef/resource'

class Chef
  class Resource
    class Zfs < Chef::Resource

	attr_accessor :exists
        
      def initialize(name, collection=nil, node=nil)
        super(name, collection, node)
        @resource_name = :zfs
	
	# resource properties
	@compression = nil
	@copies = nil
	@mountpoint = nil
	@quota = nil
	@reservation = nil
	@sharenfs = nil
	@snapdir = nil

        @action = :create

	# resource state
        @exists = nil

        @allowed_actions.push(:create, :destroy)
      end
      
      def compresssion(arg=nil)
        set_or_return(
          :compression,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def copies(arg=nil)
        set_or_return(
          :copies,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def mountpoint(arg=nil)
        set_or_return(
          :mountpoint,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def quota(arg=nil)
        set_or_return(
          :quota,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def reservation(arg=nil)
        set_or_return(
          :reservation,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def sharenfs(arg=nil)
        set_or_return(
          :sharenfs,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def snapdir(arg=nil)
        set_or_return(
          :snapdir,
          arg,
          :kind_of => [ String ]
        )
      end
      
      def exists(arg=nil)
        set_or_return(
          :exists,
          arg,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end
      
    end
  end
end

