# Service to read metadata from attention_dump.json or .as directory
class MetadataReader
  attr_reader :folder_path

  def initialize(folder_path)
    @folder_path = folder_path
  end

  def read_metadata_for_file(file_path)
    metadata = {
      file_path: file_path,
      has_metadata: false,
      attributes: {},
      priorities: {},
      facets: []
    }

    # Try to read from attention_dump.json first
    dump_file = File.join(@folder_path, 'attention_dump.json')
    if File.exist?(dump_file)
      metadata.merge!(read_from_dump(dump_file, file_path))
    end

    # Try to read from .as directory structure
    as_dir = File.join(@folder_path, '.as')
    if File.directory?(as_dir)
      metadata.merge!(read_from_as_directory(as_dir, file_path))
    end

    metadata
  end

  def read_all_metadata
    metadata = {
      has_metadata: false,
      source: nil,
      data: {}
    }

    # Try to read from attention_dump.json first
    dump_file = File.join(@folder_path, 'attention_dump.json')
    if File.exist?(dump_file)
      begin
        content = File.read(dump_file)
        metadata[:data] = JSON.parse(content)
        metadata[:has_metadata] = true
        metadata[:source] = 'attention_dump.json'
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse attention_dump.json: #{e.message}")
      end
    end

    # If no dump file, try to read from .as directory
    if !metadata[:has_metadata]
      as_dir = File.join(@folder_path, '.as')
      if File.directory?(as_dir)
        metadata[:data] = read_as_directory_structure(as_dir)
        metadata[:has_metadata] = metadata[:data].any?
        metadata[:source] = '.as directory'
      end
    end

    metadata
  end

  private

  def read_from_dump(dump_file, file_path)
    result = { has_metadata: false }
    
    begin
      content = File.read(dump_file)
      data = JSON.parse(content)
      
      relative_path = file_path.sub("#{@folder_path}/", '')
      
      # Search for file metadata in the dump
      if data.is_a?(Hash) && data.key?('files')
        file_data = data['files'][relative_path]
        if file_data
          result[:has_metadata] = true
          result[:attributes] = file_data['attributes'] || {}
          result[:priorities] = file_data['priorities'] || {}
          result[:facets] = file_data['facets'] || []
        end
      end
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse attention_dump.json: #{e.message}")
    rescue => e
      Rails.logger.error("Error reading metadata dump: #{e.message}")
    end

    result
  end

  def read_from_as_directory(as_dir, file_path)
    result = { has_metadata: false }
    
    # Look for Attributes.ini and Priorities.ini in the .as directory
    attributes_file = File.join(as_dir, 'Attributes.ini')
    priorities_file = File.join(as_dir, 'Priorities.ini')

    if File.exist?(attributes_file)
      result[:attributes] = parse_ini_file(attributes_file)
      result[:has_metadata] = true if result[:attributes].any?
    end

    if File.exist?(priorities_file)
      result[:priorities] = parse_ini_file(priorities_file)
      result[:has_metadata] = true if result[:priorities].any?
    end

    result
  end

  def read_as_directory_structure(as_dir)
    structure = {
      attributes: {},
      priorities: {}
    }

    attributes_file = File.join(as_dir, 'Attributes.ini')
    priorities_file = File.join(as_dir, 'Priorities.ini')

    structure[:attributes] = parse_ini_file(attributes_file) if File.exist?(attributes_file)
    structure[:priorities] = parse_ini_file(priorities_file) if File.exist?(priorities_file)

    structure
  end

  def parse_ini_file(file_path)
    result = {}
    current_section = nil

    File.readlines(file_path).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#', ';')

      # Check for section header
      if line =~ /^\[(.+)\]$/
        current_section = $1
        result[current_section] = {}
      elsif current_section && line =~ /^(.+?)=(.+)$/
        key = $1.strip
        value = $2.strip
        result[current_section][key] = value
      end
    end

    result
  rescue => e
    Rails.logger.error("Error parsing INI file #{file_path}: #{e.message}")
    {}
  end
end
