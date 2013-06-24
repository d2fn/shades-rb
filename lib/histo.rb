# Histogram utilities
module Shades

  # streaming histograms:
  # implementation of the clojure library from BigML: https://github.com/bigmlcom/histogram
  class DynamicHistogram

    def initialize(max_size)
      @res = StreamReservoir.new(max_size)
    end

    def add(f)
      @res.add(StreamBin.new(1, f))
      @res.compress
    end

    def lines
      @res.lines
    end


    def ascii_art
      @res.histo_text
    end
  end

  class StreamReservoir

    def initialize(max_size)
      @max_size = max_size
      @n = 0
      @bins = []
    end

    def add(bin)
      @n += bin.count
      # bind the bin index to place this data
      i = placement(bin)
      @bins.insert(i, bin)
    end

    def placement(bin)
      @bins.length.times do |i|
        if @bins[i].mean >= bin.mean
          return i
        end
      end
      return @bins.length
    end

    def compress
      while @bins.length > @max_size
        min_gap_index = -1
        min_gap = Float::MAX
        # find the bin covering the smallest range
        (@bins.length-1).times do |i|
          bin_a = @bins[i]
          bin_b = @bins[i+1]
          gap = bin_b.mean - bin_a.mean
          if min_gap > gap
            min_gap = gap
            min_gap_index = i
          end
        end
        # and merge that bin with the one to its right
        prevbin = @bins[min_gap_index]
        nextbin = @bins.delete_at(min_gap_index+1)
        prevbin.merge(nextbin)
      end
    end

    def lines
      a = []
      @bins.each do |b|
        a << "%8d %10.4f" % [b.count, b.mean]
      end
      a.join("\n")
    end

    ## outputs a histogram of the form
    # 0.502 ( 27) ##############################
    # 1.108 ( 14) ###############
    # 1.731 (  7) #######
    # 2.343 (  3) ###
    # 3.138 (  4) ####
    # 3.968 (  6) ######
    # 4.548 (  4) ####
    # 5.225 (  2) ##
    # 5.990 (  2) ##
    # 8.720 (  1) #         
    ##
    ## So, the line above that reads "0.502 ( 27) ##############################"
    ## can be read as: "There are 27 values close to 0.502"
    def histo_text
      a = []
      max_bin_count = 1
      width = 30
      @bins.each do |b|
        if b.count > max_bin_count
          max_bin_count = b.count
        end
      end
      @bins.each do |b|
        repeat = width * Float(b.count)/Float(max_bin_count)
        a << "%10.3f (%3d) %s" % [b.mean, b.count, '#' * repeat]
      end
      a.join("\n")
    end
  end

  class StreamBin

    attr_accessor :count
    attr_accessor :sum

    def initialize(count, sum)
      @count = count
      @sum = sum
    end

    def merge(sb)
      @count += sb.count
      @sum += sb.sum
    end

    def mean
      Float(@sum) / Float(@count)
    end
  end
end
