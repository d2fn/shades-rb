module Shades

  ## queries are of the form:
  ## <stat-type> <measure>[, [<stat-type>] <measure>]* by <dimension>[, <dimension>] order by <dimension|measure>[, <dimension|measure>]*
  ## for example, to get the mean load1, and load5 measures by unique combination of host role and kernel version:
  ##   mean load1, load5 by role, kernelversion
  class QueryParser

    def self.parse(qs)
      parts = qs.scan(/[\w\.]+/)
      tokens = []
      t = BeginRollupToken.new
      parts.each do |p|
        t = t.emit(p)
        tokens << t
      end
      rollups = rollups_pass(tokens)
      categorizations = categorizations_pass(tokens)
      sorting = sorting_pass(tokens)
      Query.new(:categorizations => categorizations, :rollups => rollups, :sorting => sorting)
    end

    def self.rollups_pass(tokens)
      stat = nil
      r = []
      tokens.each do |t|
        if t.kind_of? StatTypeToken
          stat = t.stat
        elsif t.kind_of? MeasureRefToken
          r << { :measure => t.text, :stat => stat }
        end
      end
      r
    end

    def self.categorizations_pass(tokens)
      d = []
      tokens.each do |t|
        if t.kind_of? DimensionRefToken
          d << t.text
        end
      end
      d
    end

    def self.sorting_pass(tokens)
      s = []
      tokens.each do |t|
        if t.kind_of? SortKeyToken
          s << { :key => t.text, :asc => true }
        end
      end
      s
    end
  end

  class Token
    attr_accessor :text
    def initialize(s)
      @text = s
    end
    def to_s
      @text
    end
  end

  class BeginRollupToken < Token
    def initialize
      super("<begin>")
    end
    def emit(s)
      StatTypeToken::parse(s)
    end
  end

  class StatTypeToken < Token
    attr_accessor :stat
    def initialize(name, stat)
      super(name)
      @stat = stat
    end

    ## context free parsing of the next token to be called by the prior token
    def self.parse(s)
      stat = Stats::StatsType::get(s)
      if stat.nil?
        nil
      else
        StatTypeToken.new(s, stat)
      end
    end

    ## given the next string, parse and return the next token
    def emit(s)
      # a measure must always follow a stat
      MeasureRefToken::parse(s)
    end
  end

  class MeasureRefToken < Token
    def self.parse(s)
      MeasureRefToken.new(s)
    end
    def emit(s)
      if s.downcase.eql?("by")
        BeginCategorizationToken::parse(s)
      else
        t = StatTypeToken::parse(s)
        if !t.nil?
          t
        else
          MeasureRefToken::parse(s)
        end
      end
    end
  end

  class BeginCategorizationToken < Token
    def self.parse(s)
      BeginCategorizationToken.new(s)
    end
    def emit(s)
      DimensionRefToken::parse(s)
    end
  end

  class DimensionRefToken < Token
    def self.parse(s)
      DimensionRefToken.new(s)
    end
    def emit(s)
      if s.downcase.eql?("order")
        OrderToken::parse(s)
      else
        DimensionRefToken::parse(s)
      end
    end
  end

  class OrderToken < Token
    def self.parse(s)
      OrderToken.new(s)
    end
    def emit(s)
      # by
      BeginSortingToken::parse(s)
    end
  end

  class BeginSortingToken < Token
    def self.parse(s)
      BeginSortingToken.new(s)
    end
    def emit(s)
      SortKeyToken::parse(s)
    end
  end

  class SortKeyToken < Token
    def self.parse(s)
      SortKeyToken.new(s)
    end
    def emit(s)
      SortKeyToken::parse(s)
    end
  end
end
