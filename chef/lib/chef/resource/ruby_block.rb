class Chef
  class Resource
    class RubyBlock < Chef::Resource
      def initialize(*args)
        super
        @resource_name = :ruby_block
        @action = :create
        @allowed_actions.push(:create)
      end

      def block(&block)
        if block
          @block = block
        else
          @block
        end
      end
    end
  end
end
