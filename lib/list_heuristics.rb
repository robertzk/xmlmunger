require 'descriptive_statistics/safe'

module XMLMunger
  class StateError < StandardError; end
  class ListHeuristics

    def self.stats(enum, which = nil)
      enum.extend(DescriptiveStatistics)
      which ||= :descriptive_statistics
      enum.public_send(which)
    end

    def initialize(list)
      raise ArgumentError, "Argument must be an array" unless list.is_a?(Array)
      @list = list
    end

    def empty?
      @empty ||= @list.count.zero?
    end

    def singleton?
      @singleton ||= @list.count == 1
    end

    def multiple?
      @multiple ||= @list.count > 1
    end

    def common_type
      @common_type ||= @list.map{|x|x.class.ancestors}.reduce(:&).first
    end

    def shared_key_hashes?
      @shared_key_hashes ||=
        multiple? &&
          common_type == Hash &&
            (keys = @list.first.keys) &&
              @list[1..-1].all? { |hash| hash.keys == keys }
    end

    def string?
      @string ||= !!(common_type <= String)
    end

    def numeric?
      @numeric ||= case
        when common_type <= Numeric
          @list
        when string?
          @list.map{ |x| to_numeric(x) }.compact
        else
          []
      end
      @numeric.count == @list.count
    end

    def hash_stats
      raise StateError, oneline(%{Can only compute hash statistics
        on lists of hashes with identical keys!}) unless shared_key_hashes?
      merged = merge_hashes(@list)
      typed = classify(merged)
      apply(typed)
    end

    private

    def apply(input)
      input.reduce({}) do |out, (var,with)|
        func = "extract_#{with[:type]}".to_sym
        self.send(func, with[:data]).each do |key,val|
          ind = var.to_s + (key ? "_#{key.to_s}" : "")
          out[ind] = val
        end
        out
      end
    end

    def to_numeric(anything)
      float = Float(anything)
      int = Integer(anything) rescue float
      float == int ? int : float
    rescue
      nil
    end

    def oneline(str)
      str.strip.gsub(/\s+/, " ")
    end

    def merge_hashes(hashes)
      keys = hashes.first.keys
      container = Hash[*keys.map{|k|[k,[]]}.flatten(1)]
      hashes.each { |hash| hash.each { |(k,v)| container[k] << v } }
      container
    end

    def is_sequence?(nums, min_length = nil)
      (min_length.nil? || nums.count >= min_length) &&
        nums == (nums.min..nums.max).to_a
    end

    def all_large?(nums)
      nums.all? { |n|
        n > 1000000
      }
    end

    def classify(hash)
      hash.reduce({}) do |acc, (var, vals)|
        type, data = identity(vals)
        acc[var] = {
          type: type,
          data: data
        }
        acc
      end
    end

    def all_type(objects, *types)
      objects.all? { |obj|
        types.any?{ |c| obj.is_a?(c) }
      }
    end

    def identity(vals)
      case
      when (unique = vals.uniq).count == 1
        return :singleton, unique.first
      when all_type(vals, TrueClass, FalseClass)
        return :boolean, vals
      when all_type(vals, Date, Time)
        dates = vals.map{ |x| x.to_date }
        epoch = Date.new(1970,1,1)
        days = dates.map { |d| (d - epoch).to_i }
        return :days, days
      when ( numbers = vals.map{ |x| to_numeric(x) } ).all?
        return :numeric, numbers
      when unique.count == vals.count
        return :unique, vals
      else
        return :duplicates, vals
      end
    end

    def extract_singleton(item)
      {nil => item}
    end

    def extract_boolean(vals)
      has, vec = 0, 0
      vals.each do |bool|
        case bool
        when FalseClass
          has |= 1
          vec -= 1
        when TrueClass
          has |= 2
          vec += 1
        end
      end
      {has: has, vec: vec}
    end

    def extract_unique(items)
      items.reduce({}) do |acc,item|
        acc[var_name_for_string(item)] = 1
        acc
      end
    end

    def extract_duplicates(items)
      h = Hash.new(0)
      items.each{ |i| h[i] += 1 }
      h.reduce({}) do |acc,(item,count)|
        acc[var_name_for_string(item)] = count
        acc
      end
    end

    def extract_days(days)
      sorted_days = days.sort
      difference_comps(sorted_days)
    end

    def extract_numeric(numbers)
      case
      when is_sequence?(numbers,3), all_large?(numbers)
        {} # do nothing; junk data
      else
        difference_comps(numbers)
      end
    end

    def difference_comps(data)
      stats = {}
      stats[:length] = data.count
      stats[:min] = data.min
      stats[:max] = data.max
      if stats[:length] > 1
        diffs = data.each_cons(2).map { |a,b| b-a }
        diffs.extend(DescriptiveStatistics)
        stats[:min_diff] = diffs.min
        stats[:max_diff] = diffs.max
        stats[:avg_diff] = diffs.median
      end
      stats
    end

    def var_name_for_string(key)
      base = "is_"
      if key.nil?
        base += "nil"
      else
        base += key.to_s.strip.gsub(/\s+/, "_").downcase
      end
      base
    end

  end
end
