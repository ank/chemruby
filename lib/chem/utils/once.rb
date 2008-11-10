module Once

  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end

  module ClassMethods
    def once(*ids) # :nodoc:
      for id in ids
	module_eval <<-"end;", __FILE__, __LINE__
        alias_method :__#{id.to_i}__, :#{id.to_s}
        private :__#{id.to_i}__
        def #{id.to_s}(*args, &block)
          if defined? @__#{id.to_i}__
            @__#{id.to_i}__
          elsif ! self.frozen?
            @__#{id.to_i}__ ||= __#{id.to_i}__(*args, &block)
          else
            __#{id.to_i}__(*args, &block)
          end
        end
      end;
      end
    end
  end

end
