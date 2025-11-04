# Service to analyze a folder and determine its Git, Framework, and MetaData profiles
class FolderAnalyzer
  attr_reader :folder_path

  def initialize(folder_path)
    @folder_path = folder_path
  end

  def analyze
    {
      git_profile: analyze_git_profile,
      framework_profile: analyze_framework_profile,
      metadata_profile: analyze_metadata_profile
    }
  end

  private

  def analyze_git_profile
    profile = {
      has_git: false,
      has_branches: false,
      has_commits: false,
      branches: [],
      current_branch: nil,
      commit_count: 0
    }

    git_dir = File.join(@folder_path, '.git')
    return profile unless File.directory?(git_dir)

    profile[:has_git] = true

    begin
      repo = Rugged::Repository.new(@folder_path)
      
      # Check branches
      branches = repo.branches.map(&:name)
      profile[:branches] = branches
      profile[:has_branches] = branches.any?
      profile[:current_branch] = repo.head.name.sub('refs/heads/', '') if repo.head_detached? == false
      
      # Check commits
      walker = Rugged::Walker.new(repo)
      walker.push(repo.head.target_id) unless repo.empty?
      profile[:commit_count] = walker.count
      profile[:has_commits] = profile[:commit_count] > 0
    rescue => e
      Rails.logger.error("Git analysis error: #{e.message}")
    end

    profile
  end

  def analyze_framework_profile
    profile = {
      ruby: analyze_ruby_framework,
      typescript: analyze_typescript_framework,
      javascript: analyze_javascript_framework,
      rust: analyze_rust_framework
    }
    profile
  end

  def analyze_ruby_framework
    ruby_profile = {
      is_gem: false,
      is_rails_app: false,
      gemfile_exists: false,
      gemspec_exists: false
    }

    gemfile_path = File.join(@folder_path, 'Gemfile')
    ruby_profile[:gemfile_exists] = File.exist?(gemfile_path)

    gemspec_files = Dir.glob(File.join(@folder_path, '*.gemspec'))
    ruby_profile[:gemspec_exists] = gemspec_files.any?
    ruby_profile[:is_gem] = ruby_profile[:gemspec_exists]

    # Check for Rails app indicators
    config_application = File.join(@folder_path, 'config', 'application.rb')
    if File.exist?(config_application)
      content = File.read(config_application)
      ruby_profile[:is_rails_app] = content.include?('Rails::Application')
    end

    ruby_profile
  end

  def analyze_typescript_framework
    ts_profile = {
      has_typescript: false,
      tsconfig_exists: false
    }

    tsconfig_path = File.join(@folder_path, 'tsconfig.json')
    ts_profile[:tsconfig_exists] = File.exist?(tsconfig_path)
    ts_profile[:has_typescript] = ts_profile[:tsconfig_exists]

    ts_profile
  end

  def analyze_javascript_framework
    js_profile = {
      has_javascript: false,
      package_json_exists: false,
      node_modules_exists: false
    }

    package_json_path = File.join(@folder_path, 'package.json')
    js_profile[:package_json_exists] = File.exist?(package_json_path)

    node_modules_path = File.join(@folder_path, 'node_modules')
    js_profile[:node_modules_exists] = File.directory?(node_modules_path)

    js_profile[:has_javascript] = js_profile[:package_json_exists]

    js_profile
  end

  def analyze_rust_framework
    rust_profile = {
      has_rust: false,
      cargo_toml_exists: false
    }

    cargo_toml_path = File.join(@folder_path, 'Cargo.toml')
    rust_profile[:cargo_toml_exists] = File.exist?(cargo_toml_path)
    rust_profile[:has_rust] = rust_profile[:cargo_toml_exists]

    rust_profile
  end

  def analyze_metadata_profile
    profile = {
      has_metadata: false,
      has_metadata_dump: false,
      as_directory_path: nil,
      dump_file_path: nil
    }

    as_dir = File.join(@folder_path, '.as')
    profile[:has_metadata] = File.directory?(as_dir)
    profile[:as_directory_path] = as_dir if profile[:has_metadata]

    dump_file = File.join(@folder_path, 'attention_dump.json')
    profile[:has_metadata_dump] = File.exist?(dump_file)
    profile[:dump_file_path] = dump_file if profile[:has_metadata_dump]

    profile
  end
end
