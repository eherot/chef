def initialize(*args)
  super
  puts "Overridden initialize"
end

actions :print_message

attribute :message, :kind_of => String
