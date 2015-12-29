require "gcloud/doc/version"
require "yard"
require "redcarpet"
require "jbuilder"

module Gcloud
  module Doc
    class Json
      attr_reader :input, :docs, :registry

      ##
      # Creates a new builder to output documentation in JSON
      #
      # @param [YARD::Registry] registry The YARD registry instance containing
      #   the source code objects
      def initialize registry
        @registry = registry
        build
      end

      def build
        modules = @registry.all(:module)
        @docs = Jbuilder.new do |json|
          json.services modules do |service|
            json.id service.name.to_s.downcase
            metadata json, service
            methods json, service
            classes = service.children.select { |c| c.type == :class && c.namespace.name == service.name }
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
            json.title md(t.text)
          end
          json.examples object.docstring.tags(:example) do |t|
            json.caption md(t.name)
            json.code t.text
          end
        end
      end

      def methods json, object
        methods = object.children.select { |c| c.type == :method && !c.is_alias? && !c.has_tag?(:private)} # TODO: handle aliases
        json.methods methods do |method|
          metadata json, method
          options = method.docstring.tags(:option)
          # merge options into parent params
          params = method.docstring.tags(:param).inject([]) do |memo, param_tag|
            memo << param_tag
            options_tags = options.select { |t| t.name == param_tag.name }
            memo += options_tags unless options_tags.empty?
            memo
          end
          if block = method.docstring.tag(:yield)
            block_params = method.docstring.tags :yieldparam
            block_params.unshift block
            params += block_params
          end
          json.params params do |param|
            param json, method, param
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

      def param json, method, param

        if param.tag_name == "option"
          # #<YARD::Tags::OptionTag:0x007fc78102ad78 @tag_name="option", @text=nil, @name="opts", @types=nil, @pair=#<YARD::Tags::DefaultTag:0x007fc78102bd40 @tag_name="option", @text="The subject", @name=":subject", @types=["String"], @defaults=nil>, @object=#<yardoc method MyModule::MyClass#example_instance_method>>
          json.name (param.name + param.pair.name).sub(":", ".")
          param = param.pair
        elsif param.tag_name == "yield"
          json.name "yield"
        elsif param.tag_name == "yieldparam"
          json.name "yield.#{param.name}"
        else
          json.name param.name
        end

        if param.tag_name == "yield"
          json.types ["block"]
        else
          json.types param.types
        end
        json.description md(param.text)

        if param.tag_name == "option" || param.tag_name == "yield"
          json.optional true
        elsif param.tag_name == "yieldparam"
          json.optional false
        else
          # extract default value from MethodObject#parameters ⇒ Array<Array(String, String)>
          # keyword argument parameter names contain trailing ":" in MethodObject#parameters, but not in Tag
          method_param_pair = method.parameters.find { |p| p[0].sub(/:\z/, "") == param.name.to_s }
          fail "no entry found for @param: '#{param.name}' in MethodObject#parameters: #{method.inspect}" unless method_param_pair
          default_value = method_param_pair[1]
          json.optional !default_value.nil?
        end

        json.default default_value if default_value
        json.nullable(default_value == "nil" || (!param.types.nil? && param.types.include?("nil")))
        # json.defaults param.defaults TODO: add default value to spec and impl
      end

      def md s, multi_paragraph = false
        html = markdown.render(s.to_s).strip.gsub("\n", " ")
        html = unwrap_paragraph(html) unless multi_paragraph
        html
      end

      def unwrap_paragraph html
        match = Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(html)
        match[1] if match
      end

      def markdown
        @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
      end
    end
  end
end
