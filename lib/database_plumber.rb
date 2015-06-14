require 'active_record'

require 'database_plumber/leak_finder'
require 'database_plumber/report'
require 'database_plumber/version'

module DatabasePlumber
  def self.log(example)
    @example = example
  end

  def self.inspect(options = {})
    leaks = LeakFinder.inspect(options)
    unless leaks.empty?
      Report.on @example, leaks
      exit! if options[:brutal]
    end
  end
end
