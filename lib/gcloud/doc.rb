require "gcloud/doc/version"
require "yard"
require "redcarpet"
require "jbuilder"

module Gcloud
  module Doc
    class Json

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
            json.id service.name.to_s.downcase
            metadata json, service
            methods json, service
            classes = service.children.select{|c| c.type == :class && c.namespace.name == service.name }
            json.pages classes do |klass|
              json.id klass.name.to_s.downcase
              metadata json, klass
              methods json, klass
            end
          end
        end
        @registry.clear
      end

      protected

      def metadata json, object
        json.metadata do
          json.name object.name.to_s
          json.description md(object.docstring.to_s, true)
          json.source object.files.first.join("#L")
          json.resources object.docstring.tags(:see) do |t|
            json.href t.name
            json.title t.text
          end
          json.examples object.docstring.tags(:example) do |t|
            json.caption md(t.name)
            json.code t.text
          end
        end
      end

      def methods json, object
        methods = object.children.select{|c| c.type == :method }
        json.methods methods do |method|
          metadata json, method
          json.params method.docstring.tags(:param) do |t|
            json.name t.name
            json.types t.types
            json.description md(t.text)
            # extract default value from MethodObject#parameters ⇒ Array<Array(String, String)>
            # keyword argument parameter names contain trailing ":" in MethodObject#parameters, but not in Tag
            default_value = method.parameters.find{|p| p[0].sub(/:\z/, "") == t.name.to_s}[1]
            json.optional !default_value.nil?
            json.nullable false # TODO: how to determine this in Ruby?
            # TODO: add default value to spec and impl
          end
          json.exceptions method.docstring.tags(:raise) do |t|
            json.type t.type
            json.description md(t.text)
          end
          json.returns method.docstring.tags(:return) do |t|
            json.types t.types
            json.description md(t.text)
          end
        end
      end

      def md s, multi_paragraph = false
        html = markdown.render(s.to_s).strip.gsub("\n", " ")
        html = unwrap_paragraph(html) unless multi_paragraph
        html
      end

      def unwrap_paragraph html
        Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(html)[1]
      end

      def markdown
        @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
      end
    end
  end
end
