module BERT
  class Encoder
    # Encode a Ruby object into a BERT.
    #   +ruby+ is the Ruby object
    #
    # Returns a BERT
    def self.encode(ruby)
      complex_ruby = convert(ruby)
      Encode.encode(complex_ruby)
    end

    # Convert complex Ruby form in simple Ruby form.
    #   +item+ is the Ruby object to convert
    #
    # Returns the converted Ruby object
    def self.convert(item)
      case item
        when Hash
          pairs = []
          item.each_pair { |k, v| pairs << BERT::Tuple[convert(k), convert(v)] }
          BERT::Tuple[:bert, :dict, pairs]
        when Tuple
          Tuple.new(item.map { |x| convert(x) })
        when Array
          item.map { |x| convert(x) }
        when nil
          BERT::Tuple[:bert, :nil]
        when TrueClass
          BERT::Tuple[:bert, :true]
        when FalseClass
          BERT::Tuple[:bert, :false]
        when Time
          BERT::Tuple[:bert, :time, item.to_i / 1_000_000, item.to_i % 1_000_000, item.usec]
        when Regexp
          options = []
          options << :caseless if item.options & Regexp::IGNORECASE > 0
          options << :extended if item.options & Regexp::EXTENDED > 0
          options << :multiline if item.options & Regexp::MULTILINE > 0
          BERT::Tuple[:bert, :regex, item.source, options]
        else
          item
      end
    end
  end
end