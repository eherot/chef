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
    class RackspaceServerList < Knife

      banner "Sub-Command: rackspace server list (options)"

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

        server_list = [ 
            h.color('ID     Name (Flavor)', :bold), 
            h.color('Public IP', :bold), 
            h.color('Private IP', :bold)
        ]

        connection.servers.all.each do |server|
          server_list << 
              h.color(
                  "#{server.id} #{server.name} (#{server.flavor_id})", 
                  to_color(server.flavor_id)
              )
          server_list << server.addresses["public"].join(', ')
          server_list << server.addresses["private"].join(', ')
        end
        puts h.list(server_list, :columns_across, 3)

      end
    end
  end
end



