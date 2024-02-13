module TeamBuilder::Grouping::Utils

  class Bucket

    def initialize(items = [])
      @items = items
    end

    def size
      @items.size
    end

    def items
      @items
    end

    def split(opts = {})
      min_size = opts.fetch(:min)
      max_size = opts.fetch(:max)

      if @items.size < max_size
        [[self], []]
      else
        all_items = @items.dup
        splits = []
        while all_items.size > 0
          splits << all_items.shift(max_size)
        end

        # Try to fill up the last split if it is too small
        last = splits.pop
        catch :cannot_distribute do
          # Iterate over the other splits (with maximum size), subtract
          # one member from each and add it to the undersized one.
          while last.size < min_size
            splits.reverse.each do |split|
              # If we would cause another split to become too small, we have to bail.
              throw :cannot_distribute if split.size == min_size

              last << split.pop
            end
          end
        end

        # If the last one is still too small, we have a rest
        if last.size < min_size
          rest = last
        else
          splits.push(last)
          rest = []
        end

        [splits.map { |split| self.class.new split }, rest]
      end
    end

  end

end
