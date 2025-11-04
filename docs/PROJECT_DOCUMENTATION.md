# MetaData Editor - Complete Project Documentation

## Project Overview

**MetaData Editor** is a Ruby on Rails application designed to analyze and edit text files with metadata tracking. It supports the [attention gem](https://github.com/magenticmarketactualskill/attention) metadata format, providing a comprehensive interface for managing file attributes, priorities, and facets.

## Requirements (Original Prompt)

### Home Screen
1. Ask user for a folder path
2. Categorize the folder in several ways:
   - **Git Profile**: Has git, Has branches, Has commits
   - **Framework Profile**: Ruby (Gem/Rails App), TypeScript, JavaScript, Rust
   - **MetaData Profile**: Has MetaData (.as directory), Has MetaData dump (attention_dump.json)

### Editor Screen
A three-column interface:
1. **Folder Tree**: Hierarchical file/folder navigation
2. **File Content**: Text editor for viewing and editing files
3. **MetaData**: Display and edit metadata (attributes, priorities, facets)

### Additional Requirements
- No authentication or authorization
- Support for attention gem metadata format

## Architecture

### Technology Stack

- **Ruby**: 3.3.6
- **Rails**: 8.1.1
- **Database**: SQLite3
- **Frontend**: Primer CSS (GitHub's design system)
- **Testing**: RSpec + Cucumber
- **Git Integration**: Rugged (libgit2 bindings)

### Application Structure

```
metadata_editor/
├── app/
│   ├── controllers/
│   │   └── editor_controller.rb       # Main controller for all editor operations
│   ├── services/
│   │   ├── folder_analyzer.rb         # Analyzes folder profiles
│   │   ├── folder_tree_builder.rb     # Builds folder tree structure
│   │   ├── metadata_reader.rb         # Reads attention metadata
│   │   └── metadata_writer.rb         # Writes attention metadata
│   ├── views/
│   │   └── editor/
│   │       └── index.html.erb         # Main three-column interface
│   └── helpers/
│       └── editor_helper.rb
├── spec/
│   └── services/                      # RSpec unit tests
├── features/                          # Cucumber BDD tests
├── config/
│   └── routes.rb                      # Application routes
├── docs/
│   ├── architecture.puml              # UML class diagram
│   └── PROJECT_DOCUMENTATION.md       # This file
├── Gemfile                            # Ruby dependencies
└── README.md                          # User-facing documentation
```

## Service Layer Details

### FolderAnalyzer

**Purpose**: Analyzes a folder and determines its Git, Framework, and MetaData profiles.

**Key Methods**:
- `analyze()`: Returns complete analysis hash
- `analyze_git_profile()`: Detects Git repository, branches, commits
- `analyze_framework_profile()`: Detects Ruby, TypeScript, JavaScript, Rust
- `analyze_metadata_profile()`: Detects .as directory and attention_dump.json

**Git Profile Detection**:
- Checks for `.git` directory
- Uses Rugged to enumerate branches
- Counts commits using Git walker
- Identifies current branch

**Framework Profile Detection**:
- **Ruby**: Looks for `Gemfile`, `*.gemspec`, `config/application.rb`
- **TypeScript**: Looks for `tsconfig.json`
- **JavaScript**: Looks for `package.json`
- **Rust**: Looks for `Cargo.toml`

**MetaData Profile Detection**:
- Checks for `.as` directory (attention gem structure)
- Checks for `attention_dump.json` file

### FolderTreeBuilder

**Purpose**: Builds a hierarchical tree structure of files and directories.

**Key Methods**:
- `build_tree()`: Returns root node with recursive children
- `build_node(path, root)`: Recursively builds tree nodes
- `skip_directory?(name)`: Filters out unwanted directories

**Skipped Directories**:
- `.git`
- `node_modules`
- `tmp`
- `log`
- `coverage`
- `.bundle`
- `vendor/bundle`

**Tree Node Structure**:
```ruby
{
  name: "filename.txt",
  path: "/absolute/path/to/file",
  relative_path: "relative/path/to/file",
  type: "file" | "directory",
  children: []  # Only for directories
}
```

### MetadataReader

**Purpose**: Reads metadata from attention_dump.json or .as directory structure.

**Key Methods**:
- `read_metadata_for_file(file_path)`: Reads metadata for specific file
- `read_all_metadata()`: Reads all metadata from folder
- `parse_ini_file(file_path)`: Parses INI format files

**Metadata Sources** (in order of preference):
1. `attention_dump.json`: JSON format with all metadata
2. `.as/Attributes.ini`: INI format for attributes
3. `.as/Priorities.ini`: INI format for priorities

**Metadata Structure**:
```ruby
{
  file_path: "/path/to/file",
  has_metadata: true,
  attributes: {
    "code_review" => "0.8",
    "documentation" => "0.5"
  },
  priorities: {
    "security_review" => "1.0",
    "refactoring" => "0.6"
  },
  facets: ["File:example.rb"]
}
```

### MetadataWriter

**Purpose**: Writes metadata changes back to attention_dump.json or .as directory.

**Key Methods**:
- `write_metadata(file_path, metadata)`: Writes metadata for specific file
- `write_all_metadata(metadata_hash)`: Writes complete metadata dump
- `write_ini_section(file_path, section_name, data)`: Writes INI sections

**Write Strategy**:
1. If `attention_dump.json` exists → update it
2. If `.as` directory exists → update INI files
3. Otherwise → create new `attention_dump.json`

## Controller Layer

### EditorController

**Purpose**: Handles all HTTP requests for the editor interface.

**Actions**:

1. **index**: Renders home screen
2. **analyze_folder**: Analyzes folder and returns profiles (POST)
3. **folder_tree**: Returns hierarchical folder tree (GET)
4. **file_content**: Returns file content for editing (GET)
5. **file_metadata**: Returns metadata for specific file (GET)
6. **update_file**: Saves file content changes (POST)
7. **update_metadata**: Saves metadata changes (POST)
8. **all_metadata**: Returns all metadata for folder (GET)

**Security**:
- CSRF verification skipped for API endpoints (no auth requirement)
- File access restricted to selected folder via `start_with?` check
- Session stores current folder path

## View Layer

### Three-Column Layout

The main interface (`editor/index.html.erb`) implements a responsive three-column layout using Primer CSS:

**Column 1: Folder Tree (300px fixed width)**
- Displays hierarchical file/folder structure
- Icons for files and directories (SVG octicons)
- Click handlers for file selection
- Scrollable overflow

**Column 2: File Content (flexible width)**
- Textarea for file editing
- Monospace font for code
- File path display
- Save button
- Responsive height calculation

**Column 3: MetaData (350px fixed width)**
- Displays current file metadata
- Editable attributes (key-value pairs)
- Editable priorities (key-value pairs with 0.0-1.0 range)
- Display of facets
- Add/remove attribute/priority buttons
- Save button

### JavaScript Functionality

**Key Functions**:
- `displayAnalysis(analysis)`: Renders folder analysis results
- `loadFolderTree()`: Fetches and displays folder tree
- `displayFolderTree(node, container, level)`: Recursively renders tree
- `loadFile(filePath)`: Loads file content into editor
- `loadFileMetadata(filePath)`: Loads metadata for file
- `displayMetadata(metadata)`: Renders metadata editor
- `addAttributeField(key, value)`: Adds attribute input fields
- `addPriorityField(key, value)`: Adds priority input fields

**AJAX Requests**:
All API calls use `fetch()` with proper CSRF token handling:
```javascript
fetch('/editor/analyze_folder', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
  },
  body: JSON.stringify({ folder_path: folderPath })
})
```

## Testing

### RSpec Unit Tests

**Location**: `spec/services/`

**Coverage**:
- `FolderAnalyzer`: Tests for Git, framework, and metadata detection
- `FolderTreeBuilder`: Tests for tree structure generation

**Example Test**:
```ruby
RSpec.describe FolderAnalyzer, type: :service do
  let(:test_folder) { Rails.root.join('tmp', 'test_folder') }
  
  it 'detects Ruby framework when Gemfile exists' do
    File.write(File.join(test_folder, 'Gemfile'), 'source "https://rubygems.org"')
    analyzer = FolderAnalyzer.new(test_folder.to_s)
    result = analyzer.analyze
    expect(result[:framework_profile][:ruby][:gemfile_exists]).to be true
  end
end
```

### Cucumber BDD Tests

**Location**: `features/`

**Feature**: Folder Analysis
- Scenario: Analyzing folder with Gemfile
- Scenario: Analyzing folder with .as directory
- Scenario: Analyzing folder with Git repository

**Example Step Definition**:
```ruby
Given('I have a folder with a Gemfile') do
  @test_folder = Rails.root.join('tmp', 'cucumber_test_folder')
  FileUtils.mkdir_p(@test_folder)
  File.write(File.join(@test_folder, 'Gemfile'), 'source "https://rubygems.org"')
end

When('I analyze the folder') do
  @analyzer = FolderAnalyzer.new(@test_folder.to_s)
  @analysis = @analyzer.analyze
end

Then('the analysis should indicate that a Gemfile exists') do
  expect(@analysis[:framework_profile][:ruby][:gemfile_exists]).to be true
end
```

## Attention Gem Integration

### Metadata Format

The application fully supports the [attention gem](https://github.com/magenticmarketactualskill/attention) format:

**Attributes.ini**:
```ini
[File:example.rb]
code_review=0.8
documentation=0.5
testing=0.3
```

**Priorities.ini**:
```ini
[File:example.rb]
security_review=1.0
refactoring=0.6
optimization=0.4
```

**attention_dump.json**:
```json
{
  "version": "1.0",
  "created_at": "2025-01-01T00:00:00Z",
  "files": {
    "example.rb": {
      "attributes": {
        "code_review": "0.8",
        "documentation": "0.5"
      },
      "priorities": {
        "security_review": "1.0",
        "refactoring": "0.6"
      },
      "facets": ["File:example.rb"]
    }
  }
}
```

### Urgency Calculation

While the application doesn't calculate urgency directly, it supports the attention gem's formula:

```
Urgency = (1 - Attribute Value) × Priority Value
```

This can be implemented in future versions or calculated externally using the attention gem's Rake tasks.

## Installation Guide

### System Requirements

- Ubuntu 22.04 or compatible Linux distribution
- Ruby 3.3.6
- Rails 8.1.1
- SQLite3
- CMake (for rugged gem compilation)

### Step-by-Step Installation

1. **Install System Dependencies**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y git curl libssl-dev libreadline-dev \
     zlib1g-dev autoconf bison build-essential libyaml-dev \
     libncurses5-dev libffi-dev libgdbm-dev sqlite3 libsqlite3-dev cmake
   ```

2. **Install Ruby 3.3.6** (using rbenv):
   ```bash
   git clone https://github.com/rbenv/rbenv.git ~/.rbenv
   git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
   echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
   echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
   source ~/.bashrc
   rbenv install 3.3.6
   rbenv global 3.3.6
   ```

3. **Extract Application**:
   ```bash
   unzip metadata_editor.zip
   cd metadata_editor
   ```

4. **Install Dependencies**:
   ```bash
   gem install bundler
   bundle install
   ```

5. **Setup Database**:
   ```bash
   rails db:migrate
   ```

6. **Start Server**:
   ```bash
   rails server
   ```

7. **Access Application**:
   Open browser to `http://localhost:3000`

## Usage Guide

### Basic Workflow

1. **Enter Folder Path**:
   - Navigate to `http://localhost:3000`
   - Enter absolute path to folder (e.g., `/home/user/my-project`)
   - Click "Analyze Folder"

2. **Review Analysis**:
   - View Git profile (branches, commits)
   - View Framework profile (detected languages/frameworks)
   - View MetaData profile (attention gem compatibility)
   - Click "Open Editor"

3. **Navigate Files**:
   - Browse folder tree in left column
   - Click any file to open it

4. **Edit File Content**:
   - Modify text in middle column
   - Click "Save File" to persist changes

5. **Edit Metadata**:
   - View/edit attributes in right column
   - View/edit priorities in right column
   - Click "+ Add Attribute" or "+ Add Priority" for new entries
   - Click "Save MetaData" to persist changes

### Advanced Usage

**Working with Existing Attention Metadata**:
- If folder has `.as` directory, metadata loads automatically
- If folder has `attention_dump.json`, it takes precedence
- Metadata saves to same format it was loaded from

**Creating New Metadata**:
- Open any file in a folder without metadata
- Add attributes and priorities in right column
- Click "Save MetaData"
- New `attention_dump.json` file is created

## API Reference

### POST /editor/analyze_folder

Analyzes a folder and returns its profiles.

**Request**:
```json
{
  "folder_path": "/path/to/folder"
}
```

**Response**:
```json
{
  "folder_path": "/path/to/folder",
  "analysis": {
    "git_profile": {
      "has_git": true,
      "has_branches": true,
      "has_commits": true,
      "branches": ["main", "develop"],
      "current_branch": "main",
      "commit_count": 42
    },
    "framework_profile": {
      "ruby": {
        "is_gem": false,
        "is_rails_app": true,
        "gemfile_exists": true
      },
      "typescript": { "has_typescript": false },
      "javascript": { "has_javascript": true },
      "rust": { "has_rust": false }
    },
    "metadata_profile": {
      "has_metadata": true,
      "has_metadata_dump": true
    }
  }
}
```

### GET /editor/folder_tree

Returns hierarchical folder tree structure.

**Response**:
```json
{
  "tree": {
    "name": "my-project",
    "path": "/path/to/my-project",
    "relative_path": ".",
    "type": "directory",
    "children": [...]
  }
}
```

### GET /editor/file_content?file_path=/path/to/file

Returns file content for editing.

**Response**:
```json
{
  "file_path": "/path/to/file",
  "content": "file contents here",
  "size": 1024,
  "modified_at": "2025-01-01T00:00:00Z"
}
```

### POST /editor/update_file

Saves file content changes.

**Request**:
```json
{
  "file_path": "/path/to/file",
  "content": "updated content"
}
```

**Response**:
```json
{
  "success": true,
  "message": "File updated successfully",
  "modified_at": "2025-01-01T00:00:00Z"
}
```

### GET /editor/file_metadata?file_path=/path/to/file

Returns metadata for specific file.

**Response**:
```json
{
  "metadata": {
    "file_path": "/path/to/file",
    "has_metadata": true,
    "attributes": {
      "code_review": "0.8"
    },
    "priorities": {
      "security_review": "1.0"
    },
    "facets": []
  }
}
```

### POST /editor/update_metadata

Saves metadata changes.

**Request**:
```json
{
  "file_path": "/path/to/file",
  "metadata": {
    "attributes": {
      "code_review": "0.8"
    },
    "priorities": {
      "security_review": "1.0"
    },
    "facets": []
  }
}
```

**Response**:
```json
{
  "success": true,
  "message": "Metadata updated successfully"
}
```

## Future Enhancements

### Potential Features

1. **Urgency Calculation Display**:
   - Calculate and display urgency scores
   - Sort files by urgency
   - Visual indicators for high-urgency items

2. **Batch Operations**:
   - Apply metadata to multiple files
   - Bulk attribute/priority updates
   - Template-based metadata

3. **Search and Filter**:
   - Search files by name
   - Filter by metadata values
   - Advanced query capabilities

4. **Visualization**:
   - Charts for completion status
   - Priority heatmaps
   - Progress tracking

5. **Integration**:
   - Direct attention gem Rake task execution
   - Git commit integration
   - CI/CD pipeline hooks

6. **Collaboration**:
   - Multi-user support (would require auth)
   - Change tracking
   - Comment system

## Troubleshooting

### Common Issues

**Issue**: "CMake is required to build Rugged"
**Solution**: Install CMake: `sudo apt-get install cmake`

**Issue**: "Access denied" when opening file
**Solution**: Ensure file is within selected folder path

**Issue**: Metadata not saving
**Solution**: Check write permissions on folder

**Issue**: Git profile not detected
**Solution**: Ensure `.git` directory exists and is valid

## License

This application is provided as-is for use with the attention gem metadata format. No specific license is applied.

## Credits

- **Attention Gem**: https://github.com/magenticmarketactualskill/attention
- **Primer CSS**: https://primer.style/
- **Rugged**: https://github.com/libgit2/rugged
- **Ruby on Rails**: https://rubyonrails.org/

---

**Document Version**: 1.0  
**Last Updated**: November 4, 2025  
**Application Version**: 1.0.0
