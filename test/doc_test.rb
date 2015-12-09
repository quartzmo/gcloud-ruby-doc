require 'test_helper'

describe Gcloud::Doc::Json, :docs do


  before do
    @builder = Gcloud::Doc::Json.new "test/fixtures/**/*.rb"
    @docs = @builder.docs.attributes!
  end

  it "must have services array at root" do
    @docs.size.must_equal 1
    @docs.keys[0].must_equal "services"
  end

  describe "when given a module" do
    it "must have a service" do
      services = @docs["services"]
      services.size.must_equal 1
      services[0]["id"].must_equal "mymodule"
    end

    it "must have service metadata" do
      metadata = @docs["services"][0]["metadata"]
      metadata["name"].must_equal "MyModule"
      metadata["description"].must_equal "<p>The outermost module in the test fixtures.</p>  <p>This is a Ruby <a href=\"http://docs.ruby-lang.org/en/2.2.0/Module.html\">module</a>.</p>"
      metadata["source"].must_equal "test/fixtures/my_module.rb#L8"
    end

    it "can have methods" do
      methods = @docs["services"][0]["methods"]
      methods.size.must_equal 1
    end
  end

  describe "when a module has a method" do

    it "must have metadata" do
      metadata = @docs["services"][0]["methods"][0]["metadata"]
      metadata["name"].must_equal "example_method"
      metadata["description"].must_equal "<p>Creates a new object for testing this library, as explained in <a href=\"https://en.wikipedia.org/wiki/Software_testing\">this article on testing</a>.</p>  <p>Each call creates a new instance.</p>"
    end

    it "must have metadata examples" do
      metadata = @docs["services"][0]["methods"][0]["metadata"]
      metadata["examples"].size.must_equal 1
      metadata["examples"][0]["caption"].must_equal "You can pass options."
      metadata["examples"][0]["code"].must_equal "return_object = Mymodule.storage \"my name\", opt_in: true do |config|\n  config.more = \"more\"\nend"
    end

    it "must have metadata resources" do
      metadata = @docs["services"][0]["methods"][0]["metadata"]
      metadata["resources"].size.must_equal 1
      metadata["resources"][0]["href"].must_equal "http://ntp.org/documentation.html"
      metadata["resources"][0]["title"].must_equal "NTP Documentation"
    end

    it "must have params" do
      params = @docs["services"][0]["methods"][0]["params"]
      params.size.must_equal 3
      params[0]["name"].must_equal "personal_name"
      params[0]["types"].must_equal ["String"]
      params[0]["description"].must_equal "The name, which can be any name as defined by <a href=\"https://en.wikipedia.org/wiki/Personal_name\">this article on names</a>"
      params[0]["optional"].must_equal false
      params[0]["nullable"].must_equal false
    end

    it "must have exceptions" do
      exceptions = @docs["services"][0]["methods"][0]["exceptions"]
      exceptions.size.must_equal 1
      exceptions[0]["type"].must_equal "ArgumentError"
      exceptions[0]["description"].must_equal "if the name is not a name as defined by <a href=\"https://en.wikipedia.org/wiki/Personal_name\">this article</a>"
    end

    it "must have returns" do
      returns = @docs["services"][0]["methods"][0]["returns"]
      returns.size.must_equal 1
      returns[0]["types"].must_equal ["MyModule::ReturnClass"]
      returns[0]["description"].must_equal "an empty object instance"
    end
  end

  describe "when given a module class" do
    it "must have a pages entry" do
      pages = @docs["services"][0]["pages"]
      pages.size.must_equal 2
      pages[0]["id"].must_equal "returnclass"
      pages[1]["id"].must_equal "myclass"
    end

    it "must have metadata" do
      metadata = @docs["services"][0]["pages"][1]["metadata"]
      metadata["name"].must_equal "MyClass"
      metadata["description"].must_equal "<p>You can use MyClass for almost anything.</p>"
    end

    it "can have methods" do
      methods = @docs["services"][0]["pages"][1]["methods"]
      methods.size.must_equal 1
    end

    describe "when a class has a method" do
      it "must have metadata" do
        metadata = @docs["services"][0]["pages"][1]["methods"][0]["metadata"]
        metadata["name"].must_equal "example_instance_method"
        metadata["description"].must_equal "<p>Creates a new object for testing this library</p>"
      end

    end
  end
end
