module Gluer
  def self.config
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(config)
  end

  class Configuration
    attr_accessor :base_path
    attr_accessor :file_loader
    attr_accessor :file_filter
    attr_accessor :magic_signature

    def initialize(options={})
      @base_path = options.fetch(:base_path, '.')
      @file_loader = options.fetch(:file_loader, Proc.new { |f| load(f) })
      @file_filter = options.fetch(:file_filter, default_file_filter)
      @magic_signature = options.fetch(:magic_signature, default_signature)
    end

  private

    def default_signature
      "#{self.class.name.split('::').first}.setup"
    end

    def default_file_filter
      Proc.new do |base_path, magic_signature|
        output = %x{cd '#{base_path}' && grep -IlFr '#{magic_signature}' --include=*.rb --exclude-dir 'spec' .}
        output.lines.map do |line|
          ::File.expand_path(line.chomp, base_path)
        end
      end
    end
  end
end
