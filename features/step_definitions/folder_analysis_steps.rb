Given('I have a folder with a Gemfile') do
  @test_folder = Rails.root.join('tmp', 'cucumber_test_folder')
  FileUtils.mkdir_p(@test_folder)
  File.write(File.join(@test_folder, 'Gemfile'), 'source "https://rubygems.org"')
end

Given('I have a folder with a .as directory') do
  @test_folder = Rails.root.join('tmp', 'cucumber_test_folder')
  FileUtils.mkdir_p(@test_folder)
  FileUtils.mkdir_p(File.join(@test_folder, '.as'))
end

Given('I have a folder with a Git repository') do
  @test_folder = Rails.root.join('tmp', 'cucumber_test_folder')
  FileUtils.mkdir_p(@test_folder)
  FileUtils.mkdir_p(File.join(@test_folder, '.git'))
end

When('I analyze the folder') do
  @analyzer = FolderAnalyzer.new(@test_folder.to_s)
  @analysis = @analyzer.analyze
end

Then('I should see that it has a Ruby framework profile') do
  expect(@analysis[:framework_profile][:ruby]).to be_present
end

Then('the analysis should indicate that a Gemfile exists') do
  expect(@analysis[:framework_profile][:ruby][:gemfile_exists]).to be true
end

Then('I should see that it has metadata') do
  expect(@analysis[:metadata_profile]).to be_present
end

Then('the metadata profile should show has_metadata as true') do
  expect(@analysis[:metadata_profile][:has_metadata]).to be true
end

Then('I should see that it has Git') do
  expect(@analysis[:git_profile]).to be_present
end

Then('the Git profile should show has_git as true') do
  expect(@analysis[:git_profile][:has_git]).to be true
end

After do
  # Clean up test folder after each scenario
  if @test_folder && File.directory?(@test_folder)
    FileUtils.rm_rf(@test_folder)
  end
end
