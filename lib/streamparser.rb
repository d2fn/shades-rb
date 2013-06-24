module Shades
  # parse a stream of events with whitespace delimited fields preceeded by metadata headers
  class StreamParser

    def initialize(&receiver)
      @dimensions = nil
      @measures = nil
      @receiver = receiver
    end

    def <<(line)
      line.strip!
      if !@metadata.nil?
        event = @metadata.parse_event(line, /\s+/)
        @receiver.call(event)
      elsif line.start_with?("#")
        parts = line.scan(/\w+/)
        if parts[0].eql?("dimensions")
          @dimensions = parts.drop(1)
        elsif parts[0].eql?("measures")
          @measures = parts.drop(1)
        end
        if !@dimensions.nil? && !@measures.nil?
          @metadata = Shades::Metadata.new(@dimensions, @measures)
        end
      else
        $stderr.puts "discarding line received before metadata"
      end
    end
  end
end
