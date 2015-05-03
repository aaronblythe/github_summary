require 'github_summary'
require 'github_summary/collection'


module GithubSummary
  class Cli
    # Set up sane defaults for all options. Also passes over the hash of the options passed in by the command line
    # @param [Hash] options A hash of options from the command line.
    # @option options [String] :test stuffs

    def initialize(options)
      @api_url = options[:api_url] == nil ? 'https://api.github.com' : options[:api_url]
      @org_name = options[:org_name] == nil ? 'rails' : options[:org_name]
      @project_name = options[:project_name] == nil ? 'rails' : options[:project_name]
    end

    # Using the options provided from the command line
    def run()
      g = GithubSummary::Collection::new(@api_url, @org_name, @project_name)
      g.formatted_summary
    end
  end
end