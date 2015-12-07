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
        # metadata["examples"][0]["code"].must_equal "TODO"
      end
    end
  end
end
