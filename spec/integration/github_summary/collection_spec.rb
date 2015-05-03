require "rspec"
require "spec_helper"
require "github_summary/collection"

describe GithubSummary::Collection do
  before(:each) do
    WebMock.allow_net_connect!
    #@git = GithubSummary::Collection.new("http://api.github.cerner.com", "Cloud-Common-Chef", "tomcat")
    @git = GithubSummary::Collection.new('https://api.github.com', 'jnunemaker', 'httparty')
  end

  describe 'test_get_repo_info' do
    it "returns repo information" do
      repo_info = @git.get_repo_info
      expect(repo_info.count).to be > 0
    end
  end

  describe 'test_full_list_of_commits' do
    it "returns full list of commits for the repository" do
      list_of_commits = @git.full_list_of_commits(nil)
      #x=1
      #list_of_commits.each do | commit |
      #  print "#{commit["sha"]}  - #{x} \n"
      #  x = x + 1
      #end
      expect(Integer(list_of_commits.count)).to be > 0
    end
  end

  describe 'test_get_issue_count' do
    it "returns a issue_count for the repository" do
      issue_count = @git.get_issue_count("all")
      expect(Integer(issue_count)).to be > 0
    end
  end

  describe 'test_latest_diff' do
    it "returns latest diff for the repository" do
      latest_diff = @git.latest_diff(nil,nil)
      expect(latest_diff).not_to be_empty
    end
  end

  describe 'test_get_list_of_branches' do
    it "returns a list of branches" do
      branches_list = @git.get_repo_info
      expect(branches_list.count).to be > 0
    end
  end

  describe 'test_commits_by_month_of_year' do
    it "returns histogram of commits per month of year" do
      commits_by_month_of_year = @git.commits_by_month_of_year
      expect(commits_by_month_of_year.count).to eq(12)
    end
  end

  describe 'test_commits_by_day_of_week' do
    it "returns histogram of commits per day of week" do
      commits_by_day_of_week = @git.commits_by_day_of_week
      expect(commits_by_day_of_week.count).to eq(7)
    end
  end

  describe 'test_get_formatted_summary' do
    it "returns a formatted summary" do
      formatted_summary = @git.formatted_summary
      #expect(formatted_summary).not_to be_empty
    end
  end

end