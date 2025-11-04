require 'rails_helper'

RSpec.describe FolderTreeBuilder, type: :service do
  let(:test_folder) { Rails.root.join('tmp', 'test_tree_folder') }
  
  before do
    FileUtils.mkdir_p(test_folder)
    FileUtils.mkdir_p(File.join(test_folder, 'subdir'))
    File.write(File.join(test_folder, 'file1.txt'), 'content')
    File.write(File.join(test_folder, 'subdir', 'file2.txt'), 'content')
  end
  
  after do
    FileUtils.rm_rf(test_folder)
  end
  
  describe '#build_tree' do
    subject { described_class.new(test_folder.to_s) }
    
    it 'builds a hierarchical tree structure' do
      tree = subject.build_tree
      
      expect(tree).to be_a(Hash)
      expect(tree[:type]).to eq('directory')
      expect(tree[:children]).to be_an(Array)
      expect(tree[:children].length).to be >= 2
    end
    
    it 'includes file and directory nodes' do
      tree = subject.build_tree
      
      file_nodes = tree[:children].select { |child| child[:type] == 'file' }
      dir_nodes = tree[:children].select { |child| child[:type] == 'directory' }
      
      expect(file_nodes).not_to be_empty
      expect(dir_nodes).not_to be_empty
    end
    
    it 'includes relative paths' do
      tree = subject.build_tree
      
      expect(tree[:relative_path]).to eq('.')
      tree[:children].each do |child|
        expect(child[:relative_path]).to be_present
      end
    end
  end
end
