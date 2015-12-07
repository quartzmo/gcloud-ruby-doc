require 'test_helper'

describe Gcloud::Doc::Json, :docs do

  describe "when given source" do

    def docs_from fixture
      @builder = Gcloud::Doc::Json.new "test/fixtures/#{fixture}"
      @builder.docs.attributes!
    end

    it "must have services array at root" do
      docs = docs_from "module.rb"
      docs.size.must_equal 1
      docs.keys[0].must_equal "services"
    end

    describe "when given a module" do
      it "must have a service" do
        docs = docs_from "module.rb"
        services = docs["services"]
        services.size.must_equal 1
        services[0]["id"].must_equal "top"
      end

      it "must have service metadata" do
        docs = docs_from "module.rb"
        metadata = docs["services"][0]["metadata"]
        metadata["name"].must_equal "Top"
        metadata["description"].must_equal "<p>The root <a href=\"http://docs.ruby-lang.org/en/2.2.0/Module.html\">module</a> in the test fixtures.</p>"
        metadata["source"].must_equal "test/fixtures/module.rb#L4"
      end

      it "must have service methods" do
        docs = docs_from "module.rb"
        docs["services"][0]["methods"].must_be :empty?
      end
    end

    describe "when given a module method" do
      it "must have a service method" do
        docs = docs_from "module_method.rb"
        methods = docs["services"][0]["methods"]

        methods.size.must_equal 1
      end
      
      it "must have metadata" do
        docs = docs_from "module_method.rb"
        metadata = docs["services"][0]["methods"][0]["metadata"]
        metadata["name"].must_equal "example_method"
        metadata["description"].must_equal "<p>Creates a new object for testing this library, as explained in <a href=\"https://en.wikipedia.org/wiki/Software_testing\">this article on testing</a>.</p>  <p>Each call creates a new instance.</p>"
      end

      it "must have metadata examples" do
        docs = docs_from "module_method.rb"
        metadata = docs["services"][0]["methods"][0]["metadata"]
        metadata["examples"].size.must_equal 1
        metadata["examples"][0]["caption"].must_equal "You can pass options."
        metadata["examples"][0]["code"].must_equal "options = { extra: \"my option extra\" }\nsome_object = Top.storage \"my name\", options do |config|\n  config.more = \"more\"\nend"
      end

      it "must have metadata resources" do
        docs = docs_from "module_method.rb"
        metadata = docs["services"][0]["methods"][0]["metadata"]
        metadata["resources"].size.must_equal 1
        metadata["resources"][0]["href"].must_equal "http://ntp.org/documentation.html"
        metadata["resources"][0]["title"].must_equal "NTP Documentation"
      end

      it "must have params" do
        docs = docs_from "module_method.rb"
        params = docs["services"][0]["methods"][0]["params"]
        params.size.must_equal 1
        params[0]["name"].must_equal "personal_name"
        params[0]["types"].must_equal ["String"]
        params[0]["description"].must_equal "The name, which can be any name as defined by <a href=\"https://en.wikipedia.org/wiki/Personal_name\">this article on names</a>"
        params[0]["optional"].must_equal false
        params[0]["nullable"].must_equal false
      end

      it "must have exceptions" do
        docs = docs_from "module_method.rb"
        exceptions = docs["services"][0]["methods"][0]["exceptions"]
        exceptions.size.must_equal 1
        exceptions[0]["type"].must_equal "ArgumentError"
        exceptions[0]["description"].must_equal "if the name is not a name as defined by <a href=\"https://en.wikipedia.org/wiki/Personal_name\">this article</a>"
      end

      it "must have returns" do
        docs = docs_from "module_method.rb"
        returns = docs["services"][0]["methods"][0]["returns"]
        returns.size.must_equal 1
        returns[0]["types"].must_equal ["Top::SomeObject"]
        returns[0]["description"].must_equal "a someobject instance"
      end
    end
  end
end
