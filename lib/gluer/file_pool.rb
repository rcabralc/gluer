require 'gluer/configuration'
require 'gluer/file'
require 'set'

module Gluer
  class FilePool
    def initialize
      clear
    end

    def get(path)
      files.fetch(path)
    end

    def clear
      @files = Hash.new
    end

    def update
      updated_file_paths = Set.new(collect)
      (current_file_paths - updated_file_paths).each do |old_path|
        files.delete(old_path).unload
      end
      updated_file_paths.each do |path|
        (files[path] ||= File.new(path)).reload
      end
    end

  private
    attr_accessor :files

    def collect
      base_path = Gluer.config.base_path
      signature = Gluer.config.magic_signature
      Gluer.config.file_filter.call(base_path, signature)
    end

    def current_file_paths
      Set.new(files.keys)
    end
  end
end
