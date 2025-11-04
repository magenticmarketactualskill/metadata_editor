class EditorController < ApplicationController
  # Skip CSRF verification for API endpoints (you mentioned no auth required)
  skip_before_action :verify_authenticity_token, only: [:update_file, :update_metadata]

  def index
    # Home screen - will show folder selection interface
  end

  def analyze_folder
    folder_path = params[:folder_path]
    
    if folder_path.blank?
      render json: { error: 'Folder path is required' }, status: :bad_request
      return
    end

    unless File.directory?(folder_path)
      render json: { error: 'Invalid folder path' }, status: :not_found
      return
    end

    # Store folder path in session
    session[:current_folder] = folder_path

    # Analyze the folder
    analyzer = FolderAnalyzer.new(folder_path)
    analysis = analyzer.analyze

    render json: {
      folder_path: folder_path,
      analysis: analysis
    }
  end

  def folder_tree
    folder_path = session[:current_folder] || params[:folder_path]
    
    if folder_path.blank? || !File.directory?(folder_path)
      render json: { error: 'No valid folder selected' }, status: :bad_request
      return
    end

    tree_builder = FolderTreeBuilder.new(folder_path)
    tree = tree_builder.build_tree

    render json: { tree: tree }
  end

  def file_content
    folder_path = session[:current_folder]
    file_path = params[:file_path]

    if file_path.blank? || !File.exist?(file_path)
      render json: { error: 'File not found' }, status: :not_found
      return
    end

    # Security check: ensure file is within the selected folder
    unless file_path.start_with?(folder_path)
      render json: { error: 'Access denied' }, status: :forbidden
      return
    end

    begin
      content = File.read(file_path)
      
      render json: {
        file_path: file_path,
        content: content,
        size: File.size(file_path),
        modified_at: File.mtime(file_path)
      }
    rescue => e
      render json: { error: "Failed to read file: #{e.message}" }, status: :internal_server_error
    end
  end

  def file_metadata
    folder_path = session[:current_folder]
    file_path = params[:file_path]

    if file_path.blank?
      render json: { error: 'File path is required' }, status: :bad_request
      return
    end

    # Security check
    unless file_path.start_with?(folder_path)
      render json: { error: 'Access denied' }, status: :forbidden
      return
    end

    metadata_reader = MetadataReader.new(folder_path)
    metadata = metadata_reader.read_metadata_for_file(file_path)

    render json: { metadata: metadata }
  end

  def update_file
    folder_path = session[:current_folder]
    file_path = params[:file_path]
    content = params[:content]

    if file_path.blank? || !File.exist?(file_path)
      render json: { error: 'File not found' }, status: :not_found
      return
    end

    # Security check
    unless file_path.start_with?(folder_path)
      render json: { error: 'Access denied' }, status: :forbidden
      return
    end

    begin
      File.write(file_path, content)
      
      render json: {
        success: true,
        message: 'File updated successfully',
        modified_at: File.mtime(file_path)
      }
    rescue => e
      render json: { error: "Failed to update file: #{e.message}" }, status: :internal_server_error
    end
  end

  def update_metadata
    folder_path = session[:current_folder]
    file_path = params[:file_path]
    metadata = params[:metadata]

    if file_path.blank?
      render json: { error: 'File path is required' }, status: :bad_request
      return
    end

    # Security check
    unless file_path.start_with?(folder_path)
      render json: { error: 'Access denied' }, status: :forbidden
      return
    end

    metadata_writer = MetadataWriter.new(folder_path)
    success = metadata_writer.write_metadata(file_path, metadata.to_unsafe_h.symbolize_keys)

    if success
      render json: {
        success: true,
        message: 'Metadata updated successfully'
      }
    else
      render json: { error: 'Failed to update metadata' }, status: :internal_server_error
    end
  end

  def all_metadata
    folder_path = session[:current_folder]

    if folder_path.blank? || !File.directory?(folder_path)
      render json: { error: 'No valid folder selected' }, status: :bad_request
      return
    end

    metadata_reader = MetadataReader.new(folder_path)
    metadata = metadata_reader.read_all_metadata

    render json: { metadata: metadata }
  end
end
