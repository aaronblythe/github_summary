# GithubSummary

Summarize a Github repository

## Installation

Add this line to your application's Gemfile:

    gem 'github_summary'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem build github_summary.gemspec
    $ gem install github_summary

## Usage

    # Will default to 'rails'
    github_summary

Or specify a project:

    github_summary -g https://api.github.com/ -o jnunemaker -p httparty

## Contributing

1. Fork it ( https://github.com/[my-github-username]/github_summary/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
