module MyModule
  ##
  # You can use MyClass for almost anything.
  class MyClass
    ##
    # Accepts many arguments for testing this library. Also accepts a block if a
    # block is given.
    #
    # Do not call this method until you have read all of its documentation.
    #
    # @see http://ruby-doc.org/core-2.2.0/Proc.html Proc objects are blocks of
    #   code that have been bound to a set of local variables.
    #
    # @param [String] policy A *policy* is a deliberate system of principles to
    #   guide decisions and achieve rational outcomes.  As defined in
    #   [policy](https://en.wikipedia.org/wiki/Policy).
    # @param [Hash] opts Optional parameters hash, not to be confused with
    #   keyword arguments.
    # @option opts [String] :subject The subject
    # @option opts [String] :body ('') The body
    #
    # @param [Integer] times a keyword argument for how many times
    # @param [String] prefix a keyword argument for the prefix
    #
    # @yield [a, b, c] Description of block
    #
    # @yieldparam [optional, types, ...] argname description
    # @yieldreturn [optional, types, ...] description
    #
    # @example You can pass a block.
    #   my_class = MyClass.new
    #   my_class.example_instance_method times: 5 do |my_config|
    #     my_config.limit = 5
    #     true
    #   end
    #
    # @example Or you can just pass simple arguments.
    #   my_class.example_instance_method {subject: "world"}, prefix: "hello"
    #
    # @return [String, nil] the contents of our object or nil if the object has not been filled with data.
    def example_instance_method policy = "ALWAYS", opts = {}, times: 10, prefix: nil
      if block_given?
        my_config = MyConfig.new
        immediate = yield my_config
        [immediate, my_config]
      end
    end
  end

  class MyConfig
    ##
    #
    attr_accessor :limit
  end
end
