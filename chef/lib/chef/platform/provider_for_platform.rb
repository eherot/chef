#
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2009 Daniel DeLeo
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

module Chef
  module Platform
    include Chef::Mixin::ParamsValidate
    
    extend self
    
    @platforms = {
      :mac_os_x => {
        :default => {
          :package => Chef::Provider::Package::Macports,
          :user => Chef::Provider::User::Dscl,
          :group => Chef::Provider::Group::Dscl
        }
      },
      :freebsd => {
        :default => {
          :group   => Chef::Provider::Group::Pw,
          :package => Chef::Provider::Package::Freebsd,
          :service => Chef::Provider::Service::Freebsd,
          :user    => Chef::Provider::User::Pw,
          :cron    => Chef::Provider::Cron
        }
      },
      :ubuntu   => {
        :default => {
          :package => Chef::Provider::Package::Apt,
          :service => Chef::Provider::Service::Debian,
          :cron => Chef::Provider::Cron,
          :mdadm => Chef::Provider::Mdadm
        }
      },
      :debian => {
        :default => {
          :package => Chef::Provider::Package::Apt,
          :service => Chef::Provider::Service::Debian,
          :cron => Chef::Provider::Cron,
          :mdadm => Chef::Provider::Mdadm
        }
      },
      :centos   => {
        :default => {
          :service => Chef::Provider::Service::Redhat,
          :cron => Chef::Provider::Cron,
          :package => Chef::Provider::Package::Yum,
          :mdadm => Chef::Provider::Mdadm
        }
      },
       :suse   => {
        :default => {
          :service => Chef::Provider::Service::Redhat,
          :cron => Chef::Provider::Cron,
          :package => Chef::Provider::Package::Zypper
        }
      },
      :redhat   => {
        :default => {
          :service => Chef::Provider::Service::Redhat,
          :cron => Chef::Provider::Cron,
          :package => Chef::Provider::Package::Yum,
          :mdadm => Chef::Provider::Mdadm
        }
      },
      :gentoo   => {
        :default => {
          :package => Chef::Provider::Package::Portage,
          :service => Chef::Provider::Service::Gentoo,
          :cron => Chef::Provider::Cron,
          :mdadm => Chef::Provider::Mdadm
        }
      },
      :solaris  => {},
      :default  => {
        :file => Chef::Provider::File,
        :directory => Chef::Provider::Directory,
        :link => Chef::Provider::Link,
        :template => Chef::Provider::Template,
        :remote_file => Chef::Provider::RemoteFile,
        :remote_directory => Chef::Provider::RemoteDirectory,
        :execute => Chef::Provider::Execute,
        :mount => Chef::Provider::Mount::Mount,
        :script => Chef::Provider::Script,
        :service => Chef::Provider::Service::Init,
        :perl => Chef::Provider::Script,
        :python => Chef::Provider::Script,
        :ruby => Chef::Provider::Script,
        :bash => Chef::Provider::Script,
        :csh => Chef::Provider::Script,
        :user => Chef::Provider::User::Useradd,
        :group => Chef::Provider::Group::Gpasswd,
        :http_request => Chef::Provider::HttpRequest,
        :route => Chef::Provider::Route,
        :ifconfig => Chef::Provider::Ifconfig,
        :ruby_block => Chef::Provider::RubyBlock,
        :erl_call => Chef::Provider::ErlCall
      }
    }
    attr_accessor :platforms
   
    def find(name, version)
      provider_map = platforms[:default].clone

      name_sym = name
      if name.kind_of?(String)
        name.downcase!
        name.gsub!(/\s/, "_")
        name_sym = name.to_sym
      end

      if platforms.has_key?(name_sym)
        if platforms[name_sym].has_key?(version)
          Chef::Log.debug("Platform #{name.to_s} version #{version} found")
          if platforms[name_sym].has_key?(:default)
            provider_map.merge!(platforms[name_sym][:default])
          end
          provider_map.merge!(platforms[name_sym][version])
        elsif platforms[name_sym].has_key?(:default)
          provider_map.merge!(platforms[name_sym][:default])
        end
      else
        Chef::Log.debug("Platform #{name} not found, using all defaults. (Unsupported platform?)")
      end
      provider_map
    end
    
    def find_provider(platform, version, resource_type)
      pmap = find(platform, version)
      rtkey = resource_type
      if resource_type.kind_of?(Chef::Resource::Base)
        return resource_type.provider if resource_type.provider
        rtkey = resource_type.resource_name.to_sym
      end
      if pmap.has_key?(rtkey)
        pmap[rtkey]
      else
        raise(
          ArgumentError,
          "Cannot find a provider for #{resource_type} on #{platform} version #{version}"
        )
      end
    end

    def provider_for_node(node, resource_type)
      find_provider_for_node(node, resource_type).new(node, resource_type)
    end

    def find_provider_for_node(node, resource_type)
      platform, version = find_platform_and_version(node)
      provider = find_provider(platform, version, resource_type)
    end

    def set(args)
      validate(
        args,
        {
          :platform => {
            :kind_of => Symbol,
            :required => false,
          },
          :version => {
            :kind_of => String,
            :required => false,
          },
          :resource => {
            :kind_of => Symbol,
          },
          :provider => {
            :kind_of => [ String, Symbol, Class ],
          }
        }
      )
      if args.has_key?(:platform)
        if args.has_key?(:version)
          if platforms.has_key?(args[:platform])
            if platforms[args[:platform]].has_key?(args[:version])
              platforms[args[:platform]][args[:version]][args[:resource].to_sym] = args[:provider]
            else
              platforms[args[:platform]][args[:version]] = {
                args[:resource].to_sym => args[:provider]
              }
            end
          else
            platforms[args[:platform]] = {
              args[:version] => {
                args[:resource].to_sym => args[:provider]
              }
            }
          end
        else
          if platforms.has_key?(args[:platform])
            if platforms[args[:platform]].has_key?(:default)
              platforms[args[:platform]][:default][args[:resource].to_sym] = args[:provider]
            else
              platforms[args[:platform]] = { :default => { args[:resource].to_sym => args[:provider] } }
            end
          else
            platforms[args[:platform]] = {
              :default => {
                args[:resource].to_sym => args[:provider]
              }
            }
          end
        end
      else
        if platforms.has_key?(:default)
          platforms[:default][args[:resource].to_sym] = args[:provider]
        else
          platforms[:default] = {
            args[:resource].to_sym => args[:provider]
          }
        end
      end
    end
    
    
  end
end