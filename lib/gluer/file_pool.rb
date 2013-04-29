require 'gluer/configuration'
require 'gluer/file'
require 'gluer/ordered_set'

module Gluer
  class FilePool
    def initialize
      clear
    end

    def get(path)
      files.detect { |file| file.path == path }
    end

    def clear
      @files = OrderedSet.new
    end

    def update
      new_files = OrderedSet.new(collect)
      diff = files - new_files
      diff.each(&:rollback_all)
      self.files = new_files
      files.each(&:reload)
    end

  private
    attr_accessor :files

    def collect
      base_path = Gluer.config.base_path
      signature = Gluer.config.magic_signature
      filtered_file_paths = Gluer.config.file_filter.call(base_path, signature)
      filtered_file_paths.map { |path| File.new(path) }
    end
  end
end
