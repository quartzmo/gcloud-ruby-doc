require "gcloud/doc/version"
require "yard"
require "redcarpet"
require "jbuilder"

module Gcloud
  module Doc
    class Builder

      attr_reader :input, :docs, :registry, :code
      # Creates a new builder to output documentation in JSON
      #
      # input- the input file pattern as an array which will be passed to Yard
      # output - the output directory where to store the JSON files, defaults to doc/json
      # options - an options hash
      def initialize input = ["lib/**/*.rb"]
        @input = Array(input).freeze
        @registry = YARD::Registry.load(@input, true)
        @code = @registry.all.dup.freeze
        build
      end

      def build
        modules = @registry.all(:module)
        @docs = Jbuilder.new do |json|
          json.services modules do |service|
            metadata json, service
            methods = service.children.select{|m| m.type == :method }
            json.methods methods do |method|
              metadata json, method
            end
          end
        end
        @registry.clear
      end

      def metadata json, object
        json.metadata do
          json.name object.name.to_s
          json.description md(object.docstring.to_s)
        end
      end

      def md s
        markdown.render(s.to_s).strip.gsub("\n", " ")
      end

      def markdown
        @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
      end
    end
  end
end
