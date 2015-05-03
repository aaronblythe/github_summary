require 'httparty'
require 'pp'
require 'time'
require 'date'

module GithubSummary
  class Collection

    def initialize(api_url, org_name, project_name)
      @api_url = api_url == nil ? "https://api.github.com" : api_url
      @org_name = org_name == nil ? "rails" : org_name
      @project_name = project_name == nil ? "rails" : project_name
      @repo_info = get_repo_info
      @all_commits = full_list_of_commits(nil)
    end

    def get_repo_info
      uri = "#{@api_url}/repos/#{@org_name}/#{@project_name}"
      response = HTTParty.get(uri, :headers => { 'Accept' => 'application/vnd.github.v3+json', 'User-Agent' => 'My_RubyGem' })
    end

    # recursive function
    # higher per_page_count means less calls (better performance)
    # lower per_page_count means more human testable on most repos
    # There is a flaw (skipping commits that are) that I cannot trace in the way that Github returns the results when the number per_page_count is lower
    def full_list_of_commits(sha)
      list = Array.new
      per_page_count = 1000
      sha = sha == nil ? @repo_info['default_branch'] : sha
      uri = "#{@api_url}/repos/#{@org_name}/#{@project_name}/commits?per_page=#{per_page_count}&sha=#{sha}"
      response = HTTParty.get(uri, :headers => { 'Accept' => 'application/vnd.github.v3+json', 'User-Agent' => 'My_RubyGem' })
      if response.headers["link"]
        resp_headers = response.headers["link"].gsub! /"|<|\; |rel=|/, ''
        next_link = resp_headers.split('>')
        if (next_link[1].eql?('next') && response.count == per_page_count)
          next_page_num = next_link[0].scan(/page=([\d]+)/).last.join(",")
          last_known_commit_num = ((Integer(next_page_num) - 1) * per_page_count) - 1
          list = full_list_of_commits(response[last_known_commit_num]["sha"])
        else
          return response
        end
      end
      #print "#{response.count} ***  #{response.first["sha"]} *** #{response.last["sha"]} \n"
      response + list
      response.take(response.size - 1) + list
    end

    def first_commit_date
      @all_commits.last["commit"]["author"]["date"]
    end

    def number_of_commits
      @all_commits.size
    end

    def get_issue_count(state)
      #Hack courtesy of http://bayne.github.io/post/counting-github-commits/
      state = state == nil ? "all" : state
      uri = "#{@api_url}/repos/#{@org_name}/#{@project_name}/issues?per_page=1&state=#{state}"
      response = HTTParty.get(uri, :headers => { 'Accept' => 'application/vnd.github.v3+json', 'User-Agent' => 'My_RubyGem' })
      response.headers["link"].scan(/page=([\d]+)/).last.join(",")
    end


    def get_top5_contributors
      uri = "#{@api_url}/repos/#{@org_name}/#{@project_name}/contributors?per_page=5"
      response = HTTParty.get(uri, :headers => { 'Accept' => 'application/vnd.github.v3+json', 'User-Agent' => 'My_RubyGem' })
      contributor_names = Array.new
      response.each do |key, contributors|
        contributor_names << key['login']
      end
      contributor_names
    end

    def get_list_of_branches
      uri = "#{@api_url}/repos/#{@org_name}/#{@project_name}/branches"
      response = HTTParty.get(uri, :headers => { 'Accept' => 'application/vnd.github.v3+json', 'User-Agent' => 'My_RubyGem' })
      branch_names = Array.new
      response.each do |key, branch|
        branch_names << key['name']
      end
      branch_names
    end

    def latest_diff(commit1,commit2)
      commits_uri = "#{@api_url}/repos/#{@org_name}/#{@project_name}/commits?per_page=2"
      commits_response = HTTParty.get(commits_uri, :headers => { 'Accept' => 'application/vnd.github.v3+json', 'User-Agent' => 'My_RubyGem' })
      commit1 = commit1 == nil ? commits_response[0]["sha"] : commit1
      commit2 = commit2 == nil ? commits_response[1]["sha"] : commit2

      uri = "#{@api_url}/repos/#{@org_name}/#{@project_name}/commits/#{commit1}"
      response = HTTParty.get(uri, :headers => { 'Accept' => 'application/vnd.github.VERSION.diff', 'User-Agent' => 'My_RubyGem' })
    end

    def commits_by_month_of_year
      #there are 13 here... due to arrays being zero based...
      months = [nil,'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
      month_count = [0,0,0,0,0,0,0,0,0,0,0,0,0]
      @all_commits.each do |commit|
        commit_date = Time.parse(commit['commit']['committer']['date'])
        month_count[commit_date.mon] = month_count[commit_date.mon] + 1
      end
      histogram = Hash.new
      range =  1...13
      range.each do |i|
        histogram.merge!({months[i] => month_count[i]})
      end
      histogram
    end

    def commits_by_day_of_week
      days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat']
      day_count = [0,0,0,0,0,0,0]
      @all_commits.each do |commit|
        commit_date = Time.parse(commit['commit']['committer']['date'])
        day_count[commit_date.wday] = day_count[commit_date.wday] + 1
      end
      histogram = Hash.new
      range =  0...7
      range.each do |i|
        histogram.merge!({days[i] => day_count[i]})
      end
      histogram
    end

    def formatted_summary
      @long_summary = "Repo name: #{@repo_info['name']} \n"
      @long_summary.concat("Repo Created date: #{@repo_info['created_at']} \n")
      @long_summary.concat("Date of first commit: #{first_commit_date} \n")
      @long_summary.concat("Most recent change: #{@repo_info['updated_at']} \n")
      @long_summary.concat("List of branches: #{get_list_of_branches.join(", ")} \n")
      @long_summary.concat("Total Number of issues: #{get_issue_count("all")} \n")
      @long_summary.concat("Number of Open issues: #{get_issue_count("open")} \n")
      @long_summary.concat("Number of Closed issues: #{get_issue_count("closed")} \n")
      @long_summary.concat("Top 5 contributors: #{get_top5_contributors.join(", ")} \n")
      @long_summary.concat("Commits by month of year: #{commits_by_month_of_year} \n")
      @long_summary.concat("Commits by month of year: #{commits_by_day_of_week} \n")
      @long_summary.concat("Latest Diff: #{latest_diff(nil,nil)} \n")

      print @long_summary
    end

  end
end
