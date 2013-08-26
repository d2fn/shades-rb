module Shades
  class Query 
    def initialize(opts)
      dimensions = []
      @dcs = opts[:categorizations].map do |d|
        dimensions.push(d)
        DimensionComputer.new(d, d)
      end unless opts[:categorizations].nil?
      @mrs = opts[:rollups].map do |r|
        MeasureRollup.new(r[:measure], r[:measure], r[:stat]) unless opts[:rollups].nil?
      end unless opts[:rollups].nil?
      @sorting = opts[:sorting]
      if !does_sorting?
        # got a query with no sorting parameters. but surely we should
        # return the info with some meaningful ordering
        # so, we choose to order by the first measure returned in the query, largest values firs
        @sorting = [{:key => outbound_measures.first, :asc => false}]
      end
      @pre = Processor.new(@dcs)
    end

    def rollup_list
      @mrs
    end

    def does_sorting?
      !@sorting.nil? && !@sorting.empty?
    end

    def does_rollups?
      !@dcs.nil? && !@dcs.empty? && !@mrs.nil? && !@mrs.empty?
    end

    def outbound_measures
      @mrs.map { |r| r.outbound_measure }
    end

    def run(events_in)
      if does_rollups?
        aggregator = Aggregator.new(self)
        events_in.each do |event|
          eout = @pre.send(event)
          if !eout.nil?
            aggregator.add(eout)
          end
        end
        results = aggregator.snapshot
      end
      if !@sorting.nil?
        results.sort! do |a, b|
          multicompare(a, b)
        end
      end
      results
    end

    def multicompare(a, b)
      c = 0
      @sorting.each do |s|
        v1 = lookup(a, s[:key])
        v2 = lookup(b, s[:key])
        asc = s[:asc]
        if v1 < v2
          c = if asc; -1 else 1 end
        elsif v2 < v1
          c = if asc; 1 else -1 end
        end
      end
      c
    end

    def lookup(e, k)
      v = e.dimension(k)
      if v.nil?
        v = e.measure(k)
      end
      natural_order(v)
    end

    def natural_order(o)
      begin
        return Float(o)
      rescue
      end
      o
    end
  end

  class Processor

    def initialize(dcs)
      @dcs = dcs
    end

    def send(event)
      # optionally filter stuff out here by some kind of predicate in the future
      ###
      # remap inbound to outbound dimensions
      d = {}
      dlist = []
      @dcs.each do |dc|
        dlist.push(dc.outbound_dimension)
        d[dc.outbound_dimension] = dc.get_value(event)
      end
      m = {}
      mlist = []
      event.measures.each do |k|
        mlist.push(k)
        m[k] = event.measure(k)
      end
      Event.new(Metadata.new(dlist, mlist), d, m)
    end
  end

  class DimensionComputer

    def initialize(inbound, outbound)
      @inbound = inbound
      @outbound = outbound
    end

    def outbound_dimension
      @outbound
    end

    def get_value(event)
      event.dimension(@inbound)
    end
  end

  class MeasureRollup

    attr_accessor :stat
    attr_accessor :outbound

    def initialize(inbound, outbound, stat)
      @inbound = inbound
      @outbound = outbound
      @stat = stat
    end

    def outbound_measure
      @outbound
    end
    def get_value(event)
      event.measure(@inbound)
    end
  end

  class Aggregator

    def initialize(query)
      @query = query
      @state = {}
    end

    def add(event)
      agg_event = AggEvent.new(@query, event)
      if @state.has_key?(agg_event.key)
        @state[event.key].add(agg_event)
      else
        @state[event.key] = agg_event
      end
    end

    def snapshot
      @state.values
    end
  end

  class AggEvent

    attr_accessor :metadata

    def initialize(query, event)
      @query = query
      @key = event.key
      @dvalues = {}
      @dlist = []
      event.dimensions.each do |k|
        @dvalues[k] = event.dimension(k)
        @dlist.push(k)
      end
      @rollup_info_by_measure = {}
      @stats_by_measure = {}
      @mlist = []
      @query.rollup_list.each do |r|
        @mlist.push(r.outbound_measure)
        outbound_measure = r.outbound_measure
        @rollup_info_by_measure[outbound_measure] = r
        initial_value = r.get_value(event)
        stat = r.stat.call
        stat.add(initial_value)
        @stats_by_measure[outbound_measure] = stat
      end
      @metadata = Metadata.new(@dlist, @mlist)
    end

    def key
      @key
    end

    def dimensions
      @dlist
    end

    def dimension(d)
      @dvalues[d]
    end

    def measure(m)
      if @stats_by_measure.has_key?(m)
        @stats_by_measure[m].get_value
      else
        0.0
      end
    end

    def measures
      @mlist
    end

    def add(event)
      measures.each do |k|
        value = @rollup_info_by_measure[k].get_value(event)
        @stats_by_measure[k].add(value)
      end
    end

    def line
      f = []
      f << dimensions.map { |k| '%s' % dimension(k) }
      f << measures.map   { |k| '%.5f' % measure(k) }
      f.join("\t")
    end

    def dimension_map
      @dvalues
    end

    def measure_map
      mm = {}
      measures.each do |k, v|
        mm[k] = measure(k)
      end
      mm
    end

    def to_map
      {
        :dimensions => @dvalues,
        :measures => measure_map
      }
    end
  end

end
