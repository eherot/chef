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
require 'chef/provider/package'
require 'chef/mixin/command'
require 'chef/resource/package'

class Chef
  class Provider
    class Package
      class Opensolaris < Chef::Provider::Package  
      
        def pkg_list_parse(line)
          installed_versions = Array.new
	  parts = line.split()
  	  if @new_resource.package_name == parts[0] # and parts[2] == 'installed'
            installed_versions << parts[1]
            installed_versions
          else
            nil
          end
        end

        def pkg_binary_path
		'pkg'
        end

      
        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          @current_resource.version(nil)
        
          # First, we need to look up whether we have the local gem installed or not
          status = popen4("#{pkg_binary_path} list #{@new_resource.package_name}") do |pid, stdin, stdout, stderr|
            stdout.each do |line|
              installed_versions = pkg_list_parse(line)
              next unless installed_versions
              # If the version we are asking for is installed, make that our current
              # version.  Otherwise, go ahead and use the highest one, which
              # happens to come first in the array.
              if installed_versions.detect { |v| v == @new_resource.version }
                Chef::Log.debug("#{@new_resource.package_name} at version #{@new_resource.version}")
                @current_resource.version(@new_resource.version)
              else
                iv = installed_versions.first
                Chef::Log.debug("#{@new_resource.package_name} at version #{iv}")
                @current_resource.version(iv)
              end
            end
          end
          
          #unless status.exitstatus == 0
          #  raise Chef::Exceptions::Package, "#{pkg_binary_path} list failed - #{status.inspect}!"
          #end
          
          @current_resource
        end

        def candidate_version
          return @candidate_version if @candidate_version

          status = popen4("#{pkg_binary_path} list -a #{@new_resource.package_name}") do |pid, stdin, stdout, stderr|
            stdout.each do |line|
              installed_versions = pkg_list_parse(line)
              next unless installed_versions
              Chef::Log.debug("candidate_version: remote pkg(s) available: #{installed_versions.inspect}")
              
              unless installed_versions.empty?
                Chef::Log.debug("candidate_version: setting install candidate version to #{installed_versions.first}")
                @candidate_version = installed_versions.first
              end
            end

          end

          unless status.exitstatus == 0
            raise Chef::Exceptions::Package, "#{pkg_binary_path} list -a failed - #{status.inspect}!"
          end
          @candidate_version
        end
      
        def install_package(name, version)
          run_command(
            :command => "#{pkg_binary_path} install #{name} "
          )
        end
      
        def upgrade_package(name, version)
          install_package(name, version)
        end
      
        def remove_package(name, version)
          if version
            run_command(
              :command => "#{pkg_binary_path} uninstall #{name} "
            )
          else
            run_command(
              :command => "#{pkg_binary_path} uninstall #{name} "
            )
          end
        end
      
        def purge_package(name, version)
          remove_package(name, version)
        end
      
      end
    end
  end
end
