module Stats

  SUM  = lambda { Sum.new(0.0)  }
  MEAN = lambda { Mean.new(0.0) }
  MIN  = lambda { Min.new(Float::MAX) }
  MAX  = lambda { Max.new(Float::MIN) }

  class StatsType
    def self.get(name)
      if name.eql?("sum")
        SUM
      elsif name.eql?("mean")
        MEAN
      elsif name.eql?("min")
        MIN
      elsif name.eql?("max")
        MAX
      end
    end
  end

  class Sum < StatsType

    def initialize(d)
      @val = d
    end

    def add(d)
      @val += d
    end

    def remove(d)
      @val -= d
    end

    def merge(stat)
      @val += stat.get_value
    end

    def get_value
      @val
    end
  end

  class Mean < StatsType

    attr_accessor :sum
    attr_accessor :n

    def initialize(d)
      @sum = 0.0
      @n = 0.0
    end

    def add(d)
      @sum += d
      @n += 1.0
    end

    def remove(d)
      @sum -= d
      @n -= 1.0
    end

    def merge(stat)
      @sum += stat.sum
      @n += stat.n
    end

    def get_value
      @sum / @n
    end
  end

  class Min < StatsType
    def initialize(d)
      @min = d
    end

    def add(d)
      @min = [@min, d].min
    end

    def remove(d)
      puts "ignoring remove"
    end

    def merge(stat)
      @min = [@min, stat.get_value].min
    end

    def get_value
      @min
    end
  end

  class Max < StatsType
    def initialize(d)
      @max = d
    end

    def add(d)
      @max = [@max, d].max
    end

    def remove(d)
      puts "ignoring remove"
    end

    def merge(stat)
      @max = [@max, stat.get_value].max
    end

    def get_value
      @max
    end
  end
end
