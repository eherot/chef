#
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

class Chef::Knife
  class PluginList < Chef::Knife
    
    banner "Sub-Command: plugin list [SEARCH_STRING|PATH_SPEC]"
    
    def run
      if @name_args.empty?
        output(available_plugins)
      else
        output(find_plugins(*@name_args))
      end
    end

    def find_plugins(*search_args)
      search_args = search_args.flatten
      available_plugins(search_args.join('_'))
    end

    def available_plugins(glob=nil)
      glob ||= '*'
      globbed_paths = load_path.map do |lib_path|
        base_path       = File.expand_path(lib_path)
        path_to_search  = File.join(lib_path, '*', 'knife_plugins',glob + '.rb')
        Dir[path_to_search].map do |plugin|
          plugin[/#{Regexp.escape(base_path + File::Separator)}(.*).rb/, 1]
        end
      end
      globbed_paths.flatten.sort
    end

    # The ruby load path. This is here so we can stub it for testing.
    def load_path
      $:
    end

  end
end