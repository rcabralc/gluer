require 'gluer/file_pool'
require 'set'

describe Gluer::FilePool do
  subject { Gluer::FilePool.new }

  let(:file_paths)     { ['path1', 'path2', 'path3'] }
  let(:reloaded_files) { Hash.new }

  def stub_file(path)
    stub('File', :path => path).tap do |file|
      file.stub(:unload)
      file.stub(:reload) { reloaded_files[path] = file }
    end
  end

  before do
    @old_file_filter = Gluer.config.file_filter
    Gluer.config.file_filter = ->(base_path, signature) { file_paths }

    Gluer::File.stub(:new) { |path| stub_file(path) }

    reloaded_files.clear
  end

  after do
    Gluer.config.file_filter = @old_file_filter
  end

  describe "#update" do
    before { subject.update }

    it "reloads each file" do
      Set[*reloaded_files.keys].should == Set[*file_paths]
    end

    it "makes them available from #get" do
      expect { subject.get('path1') }.to_not raise_error
      expect { subject.get('path2') }.to_not raise_error
      expect { subject.get('path3') }.to_not raise_error
    end

    context "when filtering doesn't change in next call" do
      before do
        @file1 = reloaded_files['path1']
        @file2 = reloaded_files['path2']
        @file3 = reloaded_files['path3']

        reloaded_files.clear
      end

      it "does not unload existing files" do
        @file1.should_not_receive(:unload)
        @file2.should_not_receive(:unload)
        @file3.should_not_receive(:unload)

        subject.update
      end

      it "keeps existing files available from #get" do
        subject.update
        expect { subject.get('path1') }.to_not raise_error
      end

      it "reloads existing files" do
        @file1.should_receive(:reload)
        @file2.should_receive(:reload)
        @file3.should_receive(:reload)

        subject.update
      end
    end

    context "when filtering changes in next call" do
      before do
        new_file_paths = file_paths - ['path1'] + ['path4']
        Gluer.config.file_filter = ->(base_path, signature) { new_file_paths }

        @file1 = reloaded_files['path1']
        @file2 = reloaded_files['path2']
        @file3 = reloaded_files['path3']

        reloaded_files.clear
      end

      it "unloads the filtered out file" do
        @file1.should_receive(:unload)

        subject.update
      end

      it "does not reload the filtered out file" do
        @file1.should_not_receive(:reload)

        subject.update
      end

      specify "getting the unloaded file results in key error" do
        subject.update
        expect { subject.get('path1') }.to raise_error(KeyError)
      end

      it "reloads existing files" do
        @file2.should_receive(:reload)
        @file3.should_receive(:reload)

        subject.update
      end

      it "loads the new file" do
        subject.update
        expect(reloaded_files.keys).to include('path4')
      end

      it "makes the new file available from #get" do
        subject.update
        expect { subject.get('path4') }.to_not raise_error
      end
    end
  end
end
