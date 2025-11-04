# MetaData Editor

A Ruby on Rails application for editing text files with metadata tracking using the [attention](https://github.com/magenticmarketactualskill/attention) gem format.

## Features

### Folder Analysis

The application analyzes folders and categorizes them in three ways:

#### Git Profile
- **Has Git**: Detects if the folder is a Git repository
- **Has Branches**: Lists all Git branches
- **Has Commits**: Shows commit count and current branch

#### Framework Profile
- **Ruby**:
  - Detects Ruby Gems (`.gemspec` files)
  - Detects Rails Applications (`config/application.rb`)
  - Detects Ruby projects (`Gemfile`)
- **TypeScript**: Detects TypeScript projects (`tsconfig.json`)
- **JavaScript**: Detects JavaScript projects (`package.json`)
- **Rust**: Detects Rust projects (`Cargo.toml`)

#### MetaData Profile
- **Has MetaData**: Detects `.as` directory at the top level
- **Has MetaData Dump**: Detects `attention_dump.json` file

### Three-Column Interface

The editor provides a clean, organized interface with three columns:

1. **Folder Tree** (Left Column)
   - Hierarchical view of all files and directories
   - Click on files to open them in the editor
   - Automatically skips common directories (`.git`, `node_modules`, etc.)

2. **File Content** (Middle Column)
   - Text editor for viewing and editing file contents
   - Monospace font for code editing
   - Save button to persist changes

3. **MetaData** (Right Column)
   - View and edit metadata for the selected file
   - **Attributes**: Key-value pairs for file attributes
   - **Priorities**: Priority values (0.0-1.0) for urgency calculation
   - **Facets**: Display of file facets
   - Save button to persist metadata changes

## Installation

### Prerequisites

- Ruby 3.3.6
- Rails 8.1.1
- SQLite3
- CMake (for rugged gem)

### Setup

1. Clone or extract the application:
   ```bash
   cd metadata_editor
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:migrate
   ```

4. Start the server:
   ```bash
   rails server
   ```

5. Open your browser and navigate to:
   ```
   http://localhost:3000
   ```

## Usage

### Step 1: Enter Folder Path

On the home screen, enter the absolute path to the folder you want to analyze and edit.

Example:
```
/home/user/my-project
```

### Step 2: Review Analysis

The application will display the folder's profiles:
- Git status and branch information
- Detected frameworks and project types
- Metadata availability

### Step 3: Open Editor

Click "Open Editor" to access the three-column interface.

### Step 4: Navigate and Edit

- **Left Column**: Click on any file in the folder tree to open it
- **Middle Column**: Edit the file content as needed, then click "Save File"
- **Right Column**: Add or modify metadata attributes and priorities, then click "Save MetaData"

## Metadata Format

The application supports the [attention gem](https://github.com/magenticmarketactualskill/attention) metadata format:

### Attributes

Attributes track completion status (0.0 = not started, 1.0 = complete):

```ini
[File:example.rb]
code_review=0.8
documentation=0.5
```

### Priorities

Priorities define importance (0.0 = no priority, 1.0 = immediate attention):

```ini
[File:example.rb]
security_review=1.0
refactoring=0.6
```

### Urgency Calculation

The attention gem calculates urgency as:

```
Urgency = (1 - Attribute Value) × Priority Value
```

This highlights tasks that are both important (high priority) and incomplete (low attribute value).

## Testing

### RSpec Tests

Run unit tests with RSpec:

```bash
bundle exec rspec
```

### Cucumber Tests

Run BDD tests with Cucumber:

```bash
bundle exec cucumber
```

## Architecture

### Services

- **FolderAnalyzer**: Analyzes folders for Git, Framework, and MetaData profiles
- **FolderTreeBuilder**: Builds hierarchical tree structure of files and directories
- **MetadataReader**: Reads metadata from `attention_dump.json` or `.as` directory
- **MetadataWriter**: Writes metadata changes back to the appropriate format

### Controllers

- **EditorController**: Handles all editor operations including:
  - Folder analysis
  - File tree generation
  - File content reading/writing
  - Metadata reading/writing

### Views

- **editor/index.html.erb**: Main interface with three-column layout using Primer CSS

## Security

- No authentication or authorization is implemented (as requested)
- File access is restricted to the selected folder and its subdirectories
- CSRF protection is disabled for API endpoints

## Dependencies

### Production
- **rails** (~> 8.1.1): Web application framework
- **primer_view_components**: GitHub's Primer design system
- **rugged**: Ruby bindings to libgit2 for Git operations
- **sqlite3**: Database adapter

### Development & Testing
- **rspec-rails**: Testing framework
- **cucumber-rails**: BDD testing framework
- **factory_bot_rails**: Test data generation
- **capybara**: Integration testing
- **selenium-webdriver**: Browser automation for tests

## License

This application is provided as-is for use with the attention gem metadata format.

## Contributing

This is a standalone application. For issues with the attention gem itself, please visit:
https://github.com/magenticmarketactualskill/attention

## Support

For questions or issues with this application, please refer to the source code and documentation provided.
