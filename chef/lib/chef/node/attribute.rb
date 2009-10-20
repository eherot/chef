#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: AJ Christensen (<aj@opscode.com>)
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

require 'chef/mixin/deep_merge'
require 'chef/log'

class Chef
  class Node
    
    class ProxyBase
      instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    end
    
    class Attribute
      attr_accessor :attribute, :default, :override
                    
      def initialize(attribute, default, override, state=[])
        @attribute = attribute
        @default = default
        @current_default = default
        @override = override
        unify_attributes
      end
      
      def unify_attributes
        unified_attributes = Mash.new
        unified_attributes = Chef::Mixin::DeepMerge.merge(unified_attributes, default)
        unified_attributes = Chef::Mixin::DeepMerge.merge(unified_attributes, attribute)
        unified_attributes = Chef::Mixin::DeepMerge.merge(unified_attributes, override)
        @unified_attributes = VividMash.new(unified_attributes)
      end
      
      def method_missing(method_name, *args, &block)
        @unified_attributes.send(method_name, *args, &block)
      end
      
      def respond_to?(method_name)
        @unified_attributes.respond_to?(method_name)
      end

      def kind_of?(klass)
        return true if klass == Chef::Node::Attribute
        @unified_attributes.kind_of?(klass)
      end
      
      def is_a?(class_or_mod)
        @unified_attributes.is_a?(class_or_mod)
      end
      
      def eval_defaults(&block)
        @unified_attributes.eval_defaults(&block)
      end
      
      def set_defaults
        @unified_attributes.set_defaults
      end
      
      def eval_with_vivifiy(&block)
        @unified_attributes.eval_with_vivifiy(&block)
      end
      
      def set_with_vivifiy
        @unified_attributes.set_with_vivifiy
      end
      
      def to_hash
        @unified_attributes.to_hash
      end
      
      def to_json
        @unified_attributes.to_json
      end
      
    end
    
    class VividMash
      
      
      
      attr_reader :mash, :auto_vivifiy_on_read, :set_unless_value_present
      
      include Enumerable
      
      def initialize(mash=nil)
        @auto_vivifiy_on_read = false
        @set_unless_value_present = false
        @mash = mash || Mash.new
        vividize_all!
      end
      
      def [](key)
       if auto_vivifiy_on_read?
         @mash[key] || begin 
           attrs_for_key = self.class.new
           attrs_for_key.auto_vivifiy_on_read = auto_vivifiy_on_read?
           attrs_to_observe << attrs_for_key
           @mash[key] = attrs_for_key
         end
       else
         @mash[key]
       end
      end

      def []=(key,value)
       if set_unless_value_present?
         @mash[key] ||= vividize_if_mash(value)
       else
         @mash[key] = vividize_if_mash(value)
       end
      end

      def attribute?(key)
       !!@mash[key]
      end

      def has_key?(key)
       attribute?(key)
      end
      alias :key? :has_key?
      alias :member? :key?
      alias :include? :key?

      def size
       @mash.size
      end
      alias :length :size

      def each(&block)
       @mash.each(&block)
      end

      def values
       @mash.values
      end

      def has_value?(val)
       @mash.has_value?(val)
      end
      alias :value? :has_value?

      def fetch(key, default_value=nil, &block)
       @mash.fetch(key, default_value) || 
       block && block.call(key) || 
       raise( ::IndexError, "Key #{key} does not exist")
      end

      def empty?
       @mash.empty?
      end

      def each_value(&block)
       @mash.each_value(&block)
      end
      
      def each_key(&block)
       @mash.each_key(&block)
      end
      
      def each_pair(&block)
       @mash.each_pair(&block)
      end
      alias :each_attribute :each_pair

      def keys
       @mash.keys
      end

      def auto_vivifiy_on_read=(auto_vivifiy_setting)
       @auto_vivifiy_on_read = auto_vivifiy_setting
       attrs_to_observe.each { |a| a.auto_vivifiy_on_read = auto_vivifiy_setting }
       @auto_vivifiy_on_read
      end

      def set_unless_value_present=(set_values_setting)
       @set_unless_value_present = set_values_setting
       attrs_to_observe.each { |a| a.set_unless_value_present = set_values_setting }
       @set_unless_value_present
      end

      def method_missing(method_name, *args, &block)
       if args.empty?
         fetch_mm_attr(method_name)
       else
         set_mm_attr(method_name, *args)
       end
      end

      def to_hash
       @mash.to_hash
      end
      
      def to_json
        @mash.to_json
      end

      def index(value)
        index = self.find do |h|
          value == h[1]
        end
        index.first if index.is_a? Array || nil
      end

      def hash_and_not_cna?(to_check)
        (! to_check.kind_of?(Chef::Node::Attribute)) && to_check.respond_to?(:has_key?)
      end
      
      def kind_of?(klass)
        @mash.kind_of?(klass) || super
      end
      
      def vivid_mash?(obj)
        obj.kind_of?(Mash) && !obj.kind_of?(Chef::Node::Attribute) && obj.kind_of?(Chef::Node::VividMash)
      end
      
      def vividizable?(obj)
        obj.kind_of?(Mash) && !obj.kind_of?(Chef::Node::VividMash)
      end
      
      def vividize_all!
        each_pair do |key, value|
          if vividizable?(value)
            new_val = vividize(value)
            new_val.vividize_all!
            self[key] = new_val
          end
        end
      end
      
      def set_defaults
        SetDefaults.new(self)
      end
      
      class SetDefaults < ProxyBase
        def initialize(vivid_mash)
          @vivid_mash = vivid_mash
        end
        
        def __is_secretly_a_set_defaults_proxy?
          true
        end
        
        def method_missing(method_name, *args, &block)
          return_obj = @vivid_mash.eval_defaults do
            self.send(method_name, *args, &block)
          end
          return_obj.respond_to?(:set_defaults) ? return_obj.set_defaults : return_obj
        end
        
      end
      
      def set_with_vivifiy
        SetWithVivify.new(self)
      end
      
      class SetWithVivify < ProxyBase
        def initialize(vivid_mash)
          @vivid_mash = vivid_mash
        end
        
        def _is_secretly_a_vivifiy_proxy?
          # for testing and debugging you can have some visibility into
          # the metaprogrammed madness. you're welcome :)
          true
        end
        
        def inspect
          "<SetWithVivify:#{@vivid_mash.inspect}>"
        end
        
        def method_missing(method_name, *args, &block)
          return_obj = @vivid_mash.eval_with_vivifiy do
            return_obj = self.send(method_name, *args, &block)
          end
          return_obj.respond_to?(:set_with_vivifiy) ? return_obj.set_with_vivifiy : return_obj
        end
        
      end
      
      
      def eval_defaults(&block)
        current_auto_viv = auto_vivifiy_on_read
        current_set_unless = set_unless_value_present
        self.auto_vivifiy_on_read = true
        self.set_unless_value_present = true
        return_obj = instance_eval(&block)
        self.auto_vivifiy_on_read = current_auto_viv
        self.set_unless_value_present = current_set_unless
        return_obj
      end
      
      def eval_with_vivifiy(&block)
        current_auto_viv = auto_vivifiy_on_read
        self.auto_vivifiy_on_read = true
        return_obj = instance_eval(&block)
        self.auto_vivifiy_on_read = current_auto_viv
        return_obj
      end

      private
      
      def attrs_to_observe
        @attrs_to_observe ||= []
      end

      def set_unless_value_present?
        @set_unless_value_present
      end

      def auto_vivifiy_on_read?
        @auto_vivifiy_on_read
      end

      def fetch_mm_attr(attr_name)
        if attribute?(attr_name) || auto_vivifiy_on_read?
          self[attr_name]
        else
          raise ArgumentError, "Attribute #{attr_name.to_s} is not defined!"
        end
      end

      def set_mm_attr(attr_name, *args)
        if attr_name.to_s =~ /^(.+)=$/
          attr_name = $1
        end
        self[attr_name] = args.length == 1 ? args[0] : args
      end
      
      def vividize_if_mash(obj)
        if obj.kind_of?(Mash) && !vivid_mash?(obj)
          v = vividize(obj)
        else
          obj
        end
      end
      
      def vividize(obj)
        vmash = self.class.new(obj)
        attrs_to_observe << vmash
        vmash
      end
      
    end
    
    
  end
end
