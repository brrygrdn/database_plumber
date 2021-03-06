module DatabasePlumber
  class LeakFinder
    class InvalidModelError < StandardError ; end

    IGNORED_AR_INTERNALS = [ActiveRecord::SchemaMigration]
    private_constant :IGNORED_AR_INTERNALS

    def self.inspect(options = {})
      new(options).inspect
    end

    def initialize(options)
      @ignored_models = (options[:ignored_models] || []) + IGNORED_AR_INTERNALS
      @ignored_adapters = options[:ignored_adapters] || []
      @model_thresholds = options[:model_thresholds] || {}
    end

    def inspect
      filtered_models.each_with_object({}) do |model, results|
        records = count_for(model)
        if records > threshold_for(model)
          results[model.to_s] = records
          mop_up(model)
        end
        results
      end
    end

    private

    def count_for(model)
      return 0 if no_table?(model)
      model.count
    rescue ActiveRecord::StatementInvalid
      raise InvalidModelError, "#{model} does not have a valid table definition"
    end

    def threshold_for(model)
      @model_thresholds.key?(model) ? @model_thresholds[model].to_i : 0
    end

    def mop_up(model)
      model.destroy_all
    end

    def no_table?(model)
      model.abstract_class? || @ignored_adapters.include?(model.connection.adapter_name.downcase.to_sym)
    end

    def filtered_models
      model_space.reject(&method(:excluded_model?))
    end

    def excluded_model?(model)
      @ignored_models.include?(model) || model.name =~ /^HABTM_/
    end

    def model_space
      ActiveRecord::Base.descendants
    end
  end
end
