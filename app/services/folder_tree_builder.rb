# Service to build a hierarchical tree structure of folders and files
class FolderTreeBuilder
  attr_reader :root_path

  def initialize(root_path)
    @root_path = root_path
  end

  def build_tree
    return nil unless File.directory?(@root_path)
    
    build_node(@root_path, @root_path)
  end

  private

  def build_node(path, root)
    relative_path = path.sub("#{root}/", '')
    relative_path = '.' if relative_path == root

    node = {
      name: File.basename(path),
      path: path,
      relative_path: relative_path,
      type: File.directory?(path) ? 'directory' : 'file',
      children: []
    }

    if File.directory?(path)
      begin
        entries = Dir.entries(path).reject { |entry| entry == '.' || entry == '..' }
        
        # Sort: directories first, then files, both alphabetically
        entries.sort_by! { |entry| [File.directory?(File.join(path, entry)) ? 0 : 1, entry.downcase] }
        
        entries.each do |entry|
          child_path = File.join(path, entry)
          # Skip certain directories to avoid clutter
          next if skip_directory?(entry)
          
          node[:children] << build_node(child_path, root)
        end
      rescue Errno::EACCES => e
        Rails.logger.warn("Access denied to directory: #{path}")
      end
    end

    node
  end

  def skip_directory?(name)
    # Skip common directories that shouldn't be shown
    skip_list = ['.git', 'node_modules', 'tmp', 'log', 'coverage', '.bundle', 'vendor/bundle']
    skip_list.include?(name)
  end
end
