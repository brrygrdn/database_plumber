require 'highline'

module DatabasePlumber
  class Report
    def self.on(example, leaks)
      puts <<-REPORT.strip_heredoc

        #{HighLine.color('#### Leaking Test', :red)}

          The spec '#{HighLine.color(spec_path_for(example), :red, :underline)}' leaves
          the following rows in the database:

      REPORT

      leaks.each(&method(:print_leak))

      puts <<-REPORT.strip_heredoc

      #{HighLine.color('#### What now?', :yellow)}

        If you are using #{HighLine.color('let!', :yellow)} or #{HighLine.color('before(:all)', :yellow)} please ensure that you use a
        corresponding #{HighLine.color('after(:all)', :yellow)} block to clean up these rows.

      REPORT
    end

    private_class_method def self.print_leak(model, count)
      puts "     - #{HighLine.color(count.to_s, :blue)} row(s) for the #{model} model \n"
    end

    private_class_method def self.spec_path_for(example)
      example.metadata[:example_group][:file_path]
    end
  end
end
