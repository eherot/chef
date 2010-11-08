#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
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

require 'chef/knife'
require 'json'

class Chef
  class Knife
    class RackspaceFlavorList < Knife

      banner "knife rackspace flavor list (options)"

      def h
        @highline ||= HighLine.new
      end

      def to_color(flavor)
          require 'highline'

          case flavor
          when 1
              c = :green
          when 2,3
              c = :yellow
          when 4
              c = :blue
          when 5
              c = :cyan
          when 6
              c = :magenta
          when 7
              c = :red
          end

          return c
      end

      def run 
        require 'fog'
        require 'highline'
        require 'net/ssh/multi'
        require 'readline'

        connection = Fog::Rackspace::Servers.new(
          :rackspace_api_key => Chef::Config[:knife][:rackspace_api_key],
          :rackspace_username => Chef::Config[:knife][:rackspace_api_username] 
        )

        flavor_list = [ 
            h.color('ID', :bold), 
            h.color('Bits', :bold),
            h.color('Cores', :bold),
            h.color('Disk(GB)', :bold),
            h.color('Name', :bold)
        ]

        connection.flavors.all.each do |flavor|
          flavor_list << flavor.id.to_s
          flavor_list << flavor.bits.to_s
          flavor_list << flavor.cores.to_s
          flavor_list << flavor.disk.to_s
          flavor_list << 
              h.color(
                  flavor.name, 
                  to_color(flavor.id)
              )
        end
        puts h.list(flavor_list, :columns_across, 5)

      end
    end
  end
end



