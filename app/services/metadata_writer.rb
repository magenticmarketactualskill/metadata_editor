# Service to write metadata to attention_dump.json or .as directory
class MetadataWriter
  attr_reader :folder_path

  def initialize(folder_path)
    @folder_path = folder_path
  end

  def write_metadata(file_path, metadata)
    # Determine which format to use based on what exists
    dump_file = File.join(@folder_path, 'attention_dump.json')
    as_dir = File.join(@folder_path, '.as')

    if File.exist?(dump_file)
      write_to_dump(dump_file, file_path, metadata)
    elsif File.directory?(as_dir)
      write_to_as_directory(as_dir, file_path, metadata)
    else
      # Create new attention_dump.json
      create_new_dump(dump_file, file_path, metadata)
    end
  end

  def write_all_metadata(metadata_hash)
    dump_file = File.join(@folder_path, 'attention_dump.json')
    
    begin
      File.write(dump_file, JSON.pretty_generate(metadata_hash))
      true
    rescue => e
      Rails.logger.error("Failed to write metadata: #{e.message}")
      false
    end
  end

  private

  def write_to_dump(dump_file, file_path, metadata)
    begin
      content = File.read(dump_file)
      data = JSON.parse(content)
      
      data['files'] ||= {}
      relative_path = file_path.sub("#{@folder_path}/", '')
      
      data['files'][relative_path] = {
        'attributes' => metadata[:attributes] || {},
        'priorities' => metadata[:priorities] || {},
        'facets' => metadata[:facets] || []
      }
      
      File.write(dump_file, JSON.pretty_generate(data))
      true
    rescue => e
      Rails.logger.error("Failed to write to dump file: #{e.message}")
      false
    end
  end

  def write_to_as_directory(as_dir, file_path, metadata)
    # Write to Attributes.ini and Priorities.ini
    attributes_file = File.join(as_dir, 'Attributes.ini')
    priorities_file = File.join(as_dir, 'Priorities.ini')

    relative_path = file_path.sub("#{@folder_path}/", '')
    section_name = "File:#{File.basename(file_path)}"

    if metadata[:attributes]&.any?
      write_ini_section(attributes_file, section_name, metadata[:attributes])
    end

    if metadata[:priorities]&.any?
      write_ini_section(priorities_file, section_name, metadata[:priorities])
    end

    true
  rescue => e
    Rails.logger.error("Failed to write to .as directory: #{e.message}")
    false
  end

  def create_new_dump(dump_file, file_path, metadata)
    relative_path = file_path.sub("#{@folder_path}/", '')
    
    data = {
      'version' => '1.0',
      'created_at' => Time.now.iso8601,
      'files' => {
        relative_path => {
          'attributes' => metadata[:attributes] || {},
          'priorities' => metadata[:priorities] || {},
          'facets' => metadata[:facets] || []
        }
      }
    }

    begin
      File.write(dump_file, JSON.pretty_generate(data))
      true
    rescue => e
      Rails.logger.error("Failed to create new dump file: #{e.message}")
      false
    end
  end

  def write_ini_section(file_path, section_name, data)
    existing_content = File.exist?(file_path) ? File.read(file_path) : ''
    
    # Parse existing content
    sections = parse_ini_content(existing_content)
    
    # Update or add section
    sections[section_name] = data
    
    # Write back
    new_content = generate_ini_content(sections)
    File.write(file_path, new_content)
  end

  def parse_ini_content(content)
    sections = {}
    current_section = nil

    content.lines.each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#', ';')

      if line =~ /^\[(.+)\]$/
        current_section = $1
        sections[current_section] = {}
      elsif current_section && line =~ /^(.+?)=(.+)$/
        key = $1.strip
        value = $2.strip
        sections[current_section][key] = value
      end
    end

    sections
  end

  def generate_ini_content(sections)
    content = []
    
    sections.each do |section_name, data|
      content << "[#{section_name}]"
      data.each do |key, value|
        content << "#{key}=#{value}"
      end
      content << ""
    end

    content.join("\n")
  end
end
