require "rspec/core/formatters/base_text_formatter"
require "parallel_tests/rspec/logger_base"

module Autospec; end

class Autospec::Formatter < RSpec::Core::Formatters::BaseTextFormatter

  RSpec::Core::Formatters.register self, :example_passed, :example_pending, :example_failed, :start_dump

  RSPEC_RESULT = "./tmp/rspec_result"

  def initialize(output)
    super
    FileUtils.mkdir_p("tmp") unless Dir.exists?("tmp")
  end

  def start(example_count)
    super
    File.delete(RSPEC_RESULT) if File.exists?(RSPEC_RESULT)
    @fail_file = File.open(RSPEC_RESULT, "w")
  end

  def example_passed(_notification)
    output.print RSpec::Core::Formatters::ConsoleCodes.wrap('.', :success)
  end

  def example_pending(_notification)
    output.print RSpec::Core::Formatters::ConsoleCodes.wrap('*', :pending)
  end

  def example_failed(notification)
    output.print RSpec::Core::Formatters::ConsoleCodes.wrap('F', :failure)
    @fail_file.puts(notification.example.metadata[:location] + " ")
    @fail_file.flush
  end

  def start_dump(notification)
    output.puts
  end

  def close(filename)
    @fail_file.close
    super(filename)
  end

end

class Autospec::ParallelFormatter < ParallelTests::RSpec::LoggerBase
  RSpec::Core::Formatters.register self, :example_failed

  def message(*args);end
  def dump_failures(*args);end
  def dump_summary(*args);end
  def dump_pending(*args);end
  def seed(*args);end

  def example_failed(notification)
    output.puts notification.example.metadata[:location] + " "
  end
end
