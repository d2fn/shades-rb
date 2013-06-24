module Stats

  SUM  = lambda { Sum.new(0.0)  }
  MEAN = lambda { Mean.new(0.0) }

  class StatsType
    def self.get(name)
      if name.eql?("sum")
        SUM
      elsif name.eql?("mean")
        MEAN
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
end
