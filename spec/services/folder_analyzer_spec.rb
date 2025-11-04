require 'rails_helper'

RSpec.describe FolderAnalyzer, type: :service do
  let(:test_folder) { Rails.root.join('tmp', 'test_folder') }
  
  before do
    FileUtils.mkdir_p(test_folder)
  end
  
  after do
    FileUtils.rm_rf(test_folder)
  end
  
  describe '#analyze' do
    subject { described_class.new(test_folder.to_s) }
    
    it 'returns a hash with git, framework, and metadata profiles' do
      result = subject.analyze
      
      expect(result).to be_a(Hash)
      expect(result).to have_key(:git_profile)
      expect(result).to have_key(:framework_profile)
      expect(result).to have_key(:metadata_profile)
    end
    
    context 'when folder has a Gemfile' do
      before do
        File.write(File.join(test_folder, 'Gemfile'), 'source "https://rubygems.org"')
      end
      
      it 'detects Ruby framework' do
        result = subject.analyze
        expect(result[:framework_profile][:ruby][:gemfile_exists]).to be true
      end
    end
    
    context 'when folder has .as directory' do
      before do
        FileUtils.mkdir_p(File.join(test_folder, '.as'))
      end
      
      it 'detects metadata profile' do
        result = subject.analyze
        expect(result[:metadata_profile][:has_metadata]).to be true
      end
    end
  end
  
  describe '#analyze_git_profile' do
    subject { described_class.new(test_folder.to_s) }
    
    it 'returns false for has_git when no .git directory exists' do
      result = subject.send(:analyze_git_profile)
      expect(result[:has_git]).to be false
    end
  end
end
