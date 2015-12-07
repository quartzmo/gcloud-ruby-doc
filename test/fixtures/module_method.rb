##
# The outermost module in the test fixtures.
module Top

  ##
  # A simple class. Does nothing.
  class SomeObject
  end

  ##
  # Creates a new object for testing this library, as explained in [this
  # article on testing](https://en.wikipedia.org/wiki/Software_testing).
  #
  # Each call creates a new instance.
  #
  # @see http://ntp.org/documentation.html NTP Documentation
  #
  # @param [String] personal_name The name, which can be any name as defined by [this
  #   article on names](https://en.wikipedia.org/wiki/Personal_name)
  #
  # @raise [ArgumentError] if the name is not a name as defined by [this
  #   article](https://en.wikipedia.org/wiki/Personal_name)
  #
  # @return [Top::SomeObject] a someobject instance
  #
  # @example You can pass options.
  #   options = { extra: "my option extra" }
  #   some_object = Top.storage "my name", options do |config|
  #     config.more = "more"
  #   end
  #
  def self.example_method personal_name, options = {}
    SomeObject.new
  end
end
