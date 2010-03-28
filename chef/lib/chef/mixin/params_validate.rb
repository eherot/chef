#
# Author:: Adam Jacob (<adam@opscode.com>)
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

class Chef
  module Mixin
    
    module ParamsValidate
      
      class ValidationFailed < ArgumentError

        # ValidationFailed errors are for validation failures (surprise!)
        # They can be used like normal argument errors for compatibility, but
        # they can also be given a Hash in the constructor to provide more info
        # about the failure. When initialized with a hash, you must provide a
        # <tt>:param</tt> key, which is the name of the parameter/attribute which was 
        # given an invalid value, a <tt>:value</tt> key, which is the value that
        # failed the validation check, and either a <tt>:reason</tt> or <tt>:message</tt> key.
        # A <tt>:reason</tt> key will be inserted in to a pre-formatted message
        # "Parameter ':param' :reason. (You gave ':value')"
        # A :message key will be used as the entire message
        def initialize(msg=nil)
          if msg.respond_to?(:keys)
            assert_valid_opts(msg)
            process_opts(msg)
            super(generate_message(msg))
          else
            super
          end
        end
        

        private
        
        def generate_message(opts)
          if opts[:reason]
            "Parameter '#{@parameter_name}' #{opts[:reason]}. (You gave #{@parameter_value.inspect})"
          elsif opts[:message]
            opts[:message]
          end
        end
        
        def process_opts(opts)
          @parameter_name = opts[:param]
          @parameter_value = opts[:value]
        end

        def assert_valid_opts(opts)
          unless (opts.key?(:param)&& opts.key?(:value)) && (opts.key?(:reason)||opts.key?(:message))
            msg = "You have to provide a :param and :value key and either a :reason or :message key "
            msg << "to create a ValidationFailed error using a hash"
            raise ArgumentError, msg
          end
        end
      end

      # Takes a hash of options, along with a map to validate them.  Returns the original
      # options hash, plus any changes that might have been made (through things like setting
      # default values in the validation map)
      #
      # For example:
      #
      #   validate({ :one => "neat" }, { :one => { :kind_of => String }})
      # 
      # Would raise an exception if the value of :one above is not a kind_of? string.  Valid
      # map options are:
      #
      # :default:: Sets the default value for this parameter.
      # :callbacks:: Takes a hash of Procs, which should return true if the argument is valid.  
      #              The key will be inserted into the error message if the Proc does not return true:
      #                 "Option #{key}'s value #{value} #{message}!"
      # :kind_of:: Ensure that the value is a kind_of?(Whatever).  If passed an array, it will ensure 
      #            that the value is one of those types.
      # :respond_to:: Ensure that the value has a given method.  Takes one method name or an array of
      #               method names.
      # :required:: Raise an exception if this parameter is missing. Valid values are true or false, 
      #             by default, options are not required.
      # :regex:: Match the value of the paramater against a regular expression.
      # :equal_to:: Match the value of the paramater with ==.  An array means it can be equal to any
      #             of the values.
      def validate(opts, map)
        #--
        # validate works by taking the keys in the validation map, assuming it's a hash, and
        # looking for _pv_:symbol as methods.  Assuming it find them, it calls the right 
        # one.  
        #++
        raise ArgumentError, "Options must be a hash" unless opts.kind_of?(Hash)
        raise ArgumentError, "Validation Map must be a hash" unless map.kind_of?(Hash)   
        
        map.each do |key, validation|
          unless key.kind_of?(Symbol) || key.kind_of?(String)
            raise ArgumentError, "Validation map keys must be symbols or strings!"
          end
          case validation
          when true
            _pv_required(opts, key)
          when false
            true
          when Hash
            validation.each do |check, carg|
              check_method = "_pv_#{check.to_s}"
              if self.respond_to?(check_method, true)
                self.send(check_method, opts, key, carg)
              else
                raise ArgumentError, "Validation map has unknown check: #{check}"
              end
            end
          end
        end
        opts
      end
          
      def set_or_return(symbol, arg, validation)
        iv_symbol = "@#{symbol.to_s}".to_sym
        map = {
          symbol => validation
        }

        if arg == nil && self.instance_variable_defined?(iv_symbol) == true
          self.instance_variable_get(iv_symbol)
        else
          opts = validate({ symbol => arg }, { symbol => validation })
          self.instance_variable_set(iv_symbol, opts[symbol])
        end
      end
            
      private
      
        # Return the value of a parameter, or nil if it doesn't exist.
        def _pv_opts_lookup(opts, key)
          if opts.has_key?(key.to_s)
            opts[key.to_s]
          elsif opts.has_key?(key.to_sym)
            opts[key.to_sym]
          else
            nil
          end
        end
        
        # Raise an exception if the parameter is not found.
        def _pv_required(opts, key, is_required=true)
          if is_required
            if (opts.has_key?(key.to_s) && opts[key.to_s] != nil) ||
                (opts.has_key?(key.to_sym) && opts[key.to_sym] != nil)
              true
            else
              raise ArgumentError, :param => key, :value => nil, :message => "Required argument #{key} is missing!"
            end
          end
        end
        
        def _pv_equal_to(opts, key, to_be)
          value = _pv_opts_lookup(opts, key)
          if value != nil
            passes = false
            [ to_be ].flatten.each do |tb|
              if value == tb
                passes = true
              end
            end
            unless passes
              raise ValidationFailed, :param => key, :value => value, :reason => "must be equal to one of: #{to_be.join(", ")}"
            end
          end
        end
        
        # Raise an exception if the parameter is not a kind_of?(to_be)
        def _pv_kind_of(opts, key, to_be)
          value = _pv_opts_lookup(opts, key)
          if value != nil
            passes = false
            [ to_be ].flatten.each do |tb|
              if value.kind_of?(tb)
                passes = true
              end
            end
            unless passes
              raise ValidationFailed, :param => key, :value => value, :reason => "must be a kind of #{to_be}"
            end
          end
        end
        
        # Raise an exception if the parameter does not respond to a given set of methods.
        def _pv_respond_to(opts, key, method_name_list)
          value = _pv_opts_lookup(opts, key)
          unless value.nil?
            [ method_name_list ].flatten.each do |method_name|
              unless value.respond_to?(method_name)
                raise ValidationFailed, :param => key, :value => value, :reason => "must respond to the #{method_name} method"
              end
            end
          end
        end
      
        # Assign a default value to a parameter.
        def _pv_default(opts, key, default_value)
          value = _pv_opts_lookup(opts, key)
          if value.nil?
            opts[key] = default_value
          end
        end
        
        # Check a parameter against a regular expression.
        def _pv_regex(opts, key, regex)
          value = _pv_opts_lookup(opts, key)
          unless value.nil?
            passes = false
            [ regex ].flatten.each do |r|
              unless value.nil?
                if r.match(value.to_s)
                  passes = true
                end
              end
            end
            unless passes
              raise ValidationFailed, :param => key, :value => value, :reason => "must match regular expression #{regex.inspect}"
            end
          end
        end
        
        # Check a parameter against a hash of proc's.
        def _pv_callbacks(opts, key, callbacks)
          raise ArgumentError, "Callback list must be a hash!" unless callbacks.kind_of?(Hash)
          value = _pv_opts_lookup(opts, key)
          unless value.nil?
            callbacks.each do |message, zeproc|
              if zeproc.call(value) != true
                raise ValidationFailed, :param => key, :value => value, :message => "Option #{key}'s value #{value} #{message}!"
              end
            end
          end
        end

        # Allow a parameter to default to @name
        def _pv_name_attribute(opts, key, is_name_attribute=true)
          if is_name_attribute
            if opts[key].nil?
              opts[key] = self.instance_variable_get("@name")
            end
          end
        end
    end
  end
end

