module Shades
  class Metadata
    attr_accessor :dimensions
    attr_accessor :measures
    def initialize(dimensions, measures)
      @dimensions = dimensions
      @measures = measures
    end

    # parse an event line that adheres to this metadat
    def parse_event(line, sep)
      values = line.split(sep)
      begin
        d = {}
        @dimensions.zip(values.take(@dimensions.length)).each do |k, v|
          d[k] = v.strip
        end
        m = {}
        @measures.zip(values.drop(@dimensions.length)).each do |k, v|
          m[k] = Float(v.strip)
        end
        return Event.new(self, d, m)
      rescue => err
        puts err.message
        puts "line: #{line}"
      end
      nil
    end
  end

  class Event

    attr_accessor :metadata

    def initialize(metadata, dimensions, measures)
      @metadata = metadata
      @dvalues = dimensions
      @mvalues = measures
      @key = @dvalues.keys.map{ |k| k + "=" + @dvalues.fetch(k) }.join(";")
    end

    def key
      @key
    end

    def dimension(d)
      @dvalues[d]
    end

    def measure(m)
      @mvalues[m]
    end

    def dimensions
      @metadata.dimensions
    end

    def measures
      @metadata.measures
    end

    def line
      f = []
      f << @metadata.dimensions.map { |k| '%s' % dimension(k) }
      f << @metadata.measures.map   { |k| '%.5f' % measure(k) }
      puts f.inspect
      f.join("\t") 
    end
  end
end

