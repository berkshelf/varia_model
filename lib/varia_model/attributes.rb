require 'hashie'
require 'hashie/hash_extensions'
require 'hashie/mash'

module VariaModel
  class Attributes < Hashie::Mash
    alias_method :old_setter, :[]=
    alias_method :old_dup, :dup

    attr_writer :coercions

    # @return [Hashie::Mash]
    def coercions
      @coercions ||= Hashie::Mash.new
    end

    def coercion(key)
      self.coercions[key]
    end

    def set_coercion(key, fun)
      self.coercions[key] = fun
    end

    # Override setter to coerce the given value if a coercion is defined
    def []=(key, value)
      coerced_value = coercion(key).present? ? coercion(key).call(value) : value
      old_setter(key, coerced_value)
    end

    # Return the containing Hashie::Mash of the given dotted path
    #
    # @param [String] path
    #
    # @return [Hashie::Mash, nil]
    def container(path)
      parts = path.split('.', 2)
      match = (self[parts[0].to_s] || self[parts[0].to_sym])
      if !parts[1] or match.nil?
        eval_as_proc(self)
      else
        match.container(parts[1])
      end
    end

    # @see {Buff::Extensions::Hash#dig}
    # @override {Buff::Extensions::Hash#dig}
    #   evaluates the Proc, if one was given
    def dig(path)
      eval_as_proc(super)
    end

    def [](key)
      eval_as_proc(super)
    end

    def dup
      mash = old_dup
      mash.coercions = self.coercions
      mash
    end

    private
      # Evaluate the given Object as a Proc. If it's a block,
      # call it. Otherwise, leave it alone.
      #
      # @param [Object]
      def eval_as_proc(obj)
        obj.is_a?(Proc) ? obj.call : obj
      end

      # Dynamically calculate the current values for the Hash, since some
      # could be a Proc.
      #
      # @return [Hash]
      def computed
        @computed ||= Hash[*self.to_hash.map { |k,v| [k, eval_as_proc(v)] }.flatten]
      end
  end
end
