require 'descriptive_statistics/safe'

module XMLMunger
  class StateError < StandardError; end
  class ListHeuristics

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

    def common_type(of = nil)
          @common_types ||= {}
                     of ||= @list
      @common_types[of] ||= of.map{|x|x.class.ancestors}.reduce(:&).first
    end

    def skipped_types
      @skipped_types ||= [:strings]
    end

    def to_variable_hash
      return {} if empty?
      return {nil => @list.first} if singleton?
      type, data = identity(@list)
      typed = { nil => { type: type, data: data } }
      apply(typed)
    end

    private

    # call data extraction functions
    # returns a variable hash
    def apply(input)
      filter_types(input).reduce({}) do |out, (var,with)|
        func = "extract_#{with[:type]}".to_sym
        self.send(func, with[:data]).each do |key,val|
          ind = [var,key].map(&:to_s).reject{ |s| s.empty? }.join('_')
          out[ind] = val
        end
        out
      end
    end

    # Allow caller to ignore certain data types
    def filter_types(input)
      to_reject = skipped_types + [:notype, :other]
      input.reject { |_,v| to_reject.include?(v[:type]) }
    end

    # assign the list of values into its proper type
    # also return the appropriate transformation of the input list
    TYPES = [:shared_key_hashes?, :boolean?, :singleton?, :days?, :numeric?, :strings?, :notype?]
    def identity(vals, memo = {})
      TYPES.each do |key|
        if compute(key, vals, memo)
          type = key[0...-1].to_sym
          val = compute(type, vals, memo)
          return type, val
        end
      end
      return :other, vals
    end

    # memoized computations for #identity
    def compute(what, vals, store)
      store[what] ||= case what
        # ifs
        when :singleton?
          compute(:unique, vals, store).count == 1
        when :boolean?
          all_type?(vals, TrueClass, FalseClass)
        when :days?
          all_type?(vals, Date, Time)
        when :numeric?
          compute(:numeric, vals, store).all?
        when :strings?
          common_type(vals) <= String
        when :shared_key_hashes?
          vals.count > 1 && compute(:hash?, vals, store) &&
            (keys = vals.first.keys) &&
            vals[1..-1].all? { |hash| hash.keys == keys }
        when :hash?
          common_type(vals) <= Hash
        when :notype?
          common_type(vals) == Object
        # thens
        when :singleton
          compute(:unique, vals, store).first
        when :unique
          vals.uniq
        when :numeric
          vals.map{ |x| to_numeric(x) }
        when :days
          dates = vals.map{ |x| x.to_date }
          epoch = Date.new(1970,1,1)
          dates.map { |d| (d - epoch).to_i }
        when :shared_key_hashes
          merge_hashes(vals)
        else
          vals
      end
    end

    # Data Extraction Functions

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

    def extract_strings(items)
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

    def extract_shared_key_hashes(hash)
      typed = hash.reduce({}) do |acc, (var, vals)|
        type, data = identity(vals)
        acc[var] = { type: type, data: data }
        acc
      end
      apply(typed)
    end

    # Utility Functions

    def to_numeric(anything)
      float = Float(anything)
      int = Integer(anything) rescue float
      float == int ? int : float
    rescue
      nil
    end

    def is_sequence?(nums, min_length = nil)
      (min_length.nil? || nums.count >= min_length) &&
        nums == (nums.min..nums.max).first(nums.count)
    end

    def all_large?(nums)
      nums.all? { |n|
        n > 1000000
      }
    end

    def all_type?(objects, *types)
      objects.all? { |obj|
        types.any?{ |c| obj.is_a?(c) }
      }
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

    # merge multiple hashes with the same keys
    # resulting hash values are arrays of the input values
    def merge_hashes(hashes)
      keys = hashes.first.keys
      container = Hash[*keys.map{|k|[k,[]]}.flatten(1)]
      hashes.each { |hash| hash.each { |(k,v)| container[k] << v } }
      container
    end

  end
end
