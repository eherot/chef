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

require 'chef/recipe'
require 'chef/resource'
require 'chef/mixin/convert_to_class_name'
require 'chef/mixin/language'

class Chef
  module Mixin
    module RecipeDefinitionDSLCore
      
      include Chef::Mixin::ConvertToClassName
      include Chef::Mixin::Language
      
      def cookbook_name
        @cookbook_name ||= ""
      end
      
      def recipe_name
        @recipe_name ||= ""
      end
      
      def collection
        @collection ||= Chef::ResourceCollection.new
      end
      
      def definitions
        @definitions ||= {}
      end
      
      def node
        @node ||= nil
      end
      
      def params
        @params ||= {}
      end
      
      def cookbook_loader
        @cookbook_loader ||= nil
      end
      
      def method_missing(method_symbol, *args, &block)
        # If we have a definition that matches, we want to use that instead.  This should
        # let you do some really crazy over-riding of "native" types, if you really want
        # to. 
        if definitions.has_key?(method_symbol)
          # This dupes the high level object, but we still need to dup the params
          new_def = definitions[method_symbol].dup
          new_def.params = new_def.params.dup
          new_def.node = node
          # This sets up the parameter overrides
          new_def.instance_eval(&block) if block
          new_recipe = Chef::Recipe.new(cookbook_name, recipe_name, node, collection, definitions, cookbook_loader)
          new_recipe.params = new_def.params
          new_recipe.params[:name] = args[0]
          new_recipe.instance_eval(&new_def.recipe)
        else
          # regular resources get dynamically defined as methods on this module
          # raise a helpful error if we get here
          rname = convert_to_class_name(method_symbol.to_s)
          raise NameError, "no resource named #{rname} could be found for #{method_symbol}"
        end
      end
      
    end
  end
end
