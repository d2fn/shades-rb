module Shades
  class Formatter
    def initialize(spacer = " ")
      @spacer = spacer
    end
    def text(out, events)
      if events.empty?
        return
      end
      metadata = events[0].metadata
      lines = []
      out.puts "# dimensions: %s" % (metadata.dimensions.join(@spacer))
      out.puts "# measures: %s"   % (metadata.measures.join(@spacer))
      events.each do |e|
        out.puts e.line
      end
    end
    def pretty_text(out, events)
      if events.empty?
        return
      end
      metadata = events[0].metadata
      lines = []
      (events.length+1).times {|i|lines[i] = []}
      metadata.dimensions.each do |d|
        w = find_longest_field(d, events)
        row = 1
        events.each do |e|
          v = e.dimension(d)
          lines[row] << "%-#{w}s" % v
          row += 1
        end
        lines[0] << "%-#{w}s" % d
      end
      metadata.measures.each do |m|
        row = 1
        max_value = find_abs_max(m, events) + 1.0
        vlen = Integer(Math::log10(10*max_value)) + 5
        w = [vlen, m.length].max
        events.each do |e|
          v = e.measure(m)
          lines[row] << "%#{w}.4f" % v
          row +=1 
        end
        lines[0] << "%-#{w}s" % m
      end
      lines.map{|l|l.join(@spacer)}.each do |line|
        out.puts line
      end
    end
    def find_abs_max(m, events)
      events.inject(Float::MIN) { |max, e| [max, e.measure(m).abs].max }
    end 
    def find_longest_field(d, events)
      events.inject(d.length) { |max, e| [max, e.dimension(d).length].max }
    end
  end
end
