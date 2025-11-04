Feature: Folder Analysis
  As a user
  I want to analyze a folder
  So that I can see its Git, Framework, and MetaData profiles

  Scenario: Analyzing a folder with a Gemfile
    Given I have a folder with a Gemfile
    When I analyze the folder
    Then I should see that it has a Ruby framework profile
    And the analysis should indicate that a Gemfile exists

  Scenario: Analyzing a folder with .as directory
    Given I have a folder with a .as directory
    When I analyze the folder
    Then I should see that it has metadata
    And the metadata profile should show has_metadata as true

  Scenario: Analyzing a folder with Git repository
    Given I have a folder with a Git repository
    When I analyze the folder
    Then I should see that it has Git
    And the Git profile should show has_git as true
