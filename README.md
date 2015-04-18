[![Build Status](https://travis-ci.org/wallerjake/toolshed.svg?branch=master)](https://travis-ci.org/wallerjake/toolshed)
[![Code Climate](https://codeclimate.com/github/wallerjake/toolshed.png)](https://codeclimate.com/github/wallerjake/toolshed)

# Toolshed

Toolshed was made to make every day tasks for a developer easier and faster. It gives yout the ability to configure your environment with settings and then run tasks with one command. For example creating a pull request can require you to go up to Github. Click on create pull request. Select which branch you are creating the pull request for. Put in a title and a description. Then hit create pull request. Also Possibly needing to copy the pull request URL over the ticket it's related to. This can be a time consuming process. With Toolshed you can automated this process and get it down to one command for all of your tickets. If it does not do everything you disire it's easy to extend what is already there and add your own ticket tracking system in. Pull requests are always welcome for adding a new system in.

## Installation

Add this line to your application's Gemfile:

    gem 'toolshed'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install toolshed

## Usage

After installing the gem run toolshed from the command line for help menu.

### .toolshedrc

The .toolshedrc file is the configuration file for toolshed. This file shall never be committed to version control as you are storing password and other secure data inside of it. The purpose of this file is to store configuration per project or globally. You can store this file in your projects directory or store it in any below directories. For example it could be stored at /home/sample/.toolshedrc for a global configuration. Otherwise it can be stored at /home/sample/projects/sample_project/.toolshedrc for configuration specific to that project. Once it finds a configuration file it will no longer look down the chain. So if you use a project specific .toolshedrc file that is the only configuration file it will look at.

#### Options

* Required
  * ticket_tracking_tool: github
    * Options: github, jira and pivital_tracker
  * pull_from_remote_name: origin
    * This is where pulling will come from. This is the name you call the remote locally. By default of course it's origin but you can change this.
  * pull_from_repository_user: origin
    * This is the repository name you are pulling from. By default it's called origin.
  * pull_from_repository_name: origin
    * This is the repository name you are pulling from. By default it's called origin.
  * push_to_repository_name: origin
    * This is where pushing will come from. This is the name you call the remote locally. By default of course it's origin but you can change this.
  * push_to_repository_user: origin
    * This is the repository name you are pushing from. By default it's called origin.
  * push_to_remote_name: sample
    * This is the repository name you are pushing from. By default it's called origin.

* Optional
  * git_tool: github
    * This is not required but should be provided if using a different tool than Github.
  * github_username: sample_user
  * github_password: sample_password
  * github_token: token_123
    * Create the token if your account require's two factor authentication. You can disable this token or enable it through Github. See https://github.com/settings/tokens/new for details.
  * use_git_submodules: false
    * If you are using Git submodules you may want to turn this option on. By default it's off and not in use.
  * default_pull_request_title_format: [id] - [title]
    * If you want to provide formatting for the pull request title. The default is just to provide the title of the ticket. But you can add this line to format it to include other fields like id. You will need to figure out what the ticket system calls it. For example Pivital Tracker may call it a story_name while Jira may call it a title.
  * pivotal_tracker_username: sample_user
  * pivotal_tracker_password: sample_password
  * default_pivotal_tracker_project_id: 123
    * If no project_id is pass in on commands this will be used by default.
  * ticket_status_for_complete: 'Complete'
    * This is only used when creating a pull request. This will allow the tool to flip the status of a ticket to the next stage. Allows you to automate creating a pull request.
  * time_tracking_username: sample_username
    * If you are using a time tracking system you can use this to set it up. Currently only Harvest is supported.
  * time_tracking_password: sample_password
    * Same as time_tracking_username just for the password field.
  * time_tracking_owner: owner_name
    * Some time tracking systems require an owner to be set. This is probably the company name if using Harvest.
  * time_tracking_default_project_id: 123
    * If the time tracking system has project_ids you can set the default here.
  * time_tracking_tool: harvest
    * Options: harvest
      * Additional time tracking tools could be supported in the future.
  * home_server_password: "sample1234"
    * You can provide a name for reference when using the SSH command.
    * Example: toolshed ssh --user="sample" --host="localhost" --commands="sudo apt-get update;sudo apt-get dist-upgrade;" --password="home_server_password" --sudo-password="home_server_password"
      * This command will allow you to automate updates on an Ubuntu server. This should really only be used for small commands that do not require a lot of logic.

### Available Commands

* **help**
 * Commands that are available and what the commands do.
* **create_pull_request**
  * Give's the ability to create a pull request. Currently only Github is supported at this time.
  * Options
    * **--tool** "github"
      * You can provide the tool you are creating the pull request for. Currently only Github is available but other tools could be added in the future.
    * **--ticket-system** "pivotal_tracker"
      * The ticket system you are using. This can be provided to automatically put the pull request URI into the ticket provided.
      * **Supports**
        * pivotal_tracker
        * jira
    * **--use-defaults** "true"
      * If provided it will just select defaults for each step instead of requiring a prompt for you to input the values.
    * **--title** "Title of pull request"
      * If provided it will not prompt you for the title of the pull request but instead use this value.
    * **--body** "Body of pull request"
      * If provided it will not prompt you for the body of the pull request but instead use this value.
* **ticket_information**
  * Get the ticket information
  * Options
    * **--use-defaults**  "true|false"
      * If you want to use defaults ticket_id is taken from branch_name otherwise configuration is used
    * **--clipboard** "true|false"
      * Copy the output to the system clipboard (Mac OSx) tested
    * **--field** "field_name"
      * The field you want to either output or copy to the clipboard
    * **--formatted-string** "{name} - {url}"
      * Pass a formatted string in ticket name and url in this case and it will return that string replaced by the actual value
* **create_pivotal_tracker_note**
  * create a note for a specific PivotalTracker story based on project_id and story_id
* **update_pivotal_tracker_story_status**
  * Update the status of PivotalTracker story
* **create_branch**
  * Create a branch default (git) and push it to your local repository
  * Options
    * **--branch-name** "123_test"
      * The branch name. The standard is [ticket_id]_description
    * **--branch-from** "master"
      * What branch do you want to branch from
* **checkout_branch**
  * Checkout a branch [default git] and update the submodules if true
  * Options
    * **--branch-name** "123"
      * Branch name or part of the branch name you want to checkout
* **push_branch**
  * Push your current working branch to your own repository
  * Options
    * **--force**
      * Push your current working branch up with --force after
    * **--branch-name** "another"
      * Push this specific branch up instead of your current working branch
* **get_daily_time_update**
  * Get a daily update from your time tracking tool currently *harvest* is supported
  * Options
    * **--format** "html|text"
      * Format you want. If you want html it will open an html page in your broswer otherwise puts out plain text
    * **--use-defaults** "true|false"
      * If you want to use your default project_id instead of entering it
    * **--project-id** "1234"
      * If you want to use a project id other than your defaults.
* **list_branches**
  * List branches for your remote repository.
  * Options
    * **--repository-name** "depot"
      * The repository name you want to list branches for. If it's not passed pull_from_repository_name is used.
* **delete_branch**
  * Delete a branch both locally and remote.
  * Options
    * **--branch-name** "134_mybranch" | "134"
      * Either the full branch name or some unique string in the branch i.e. ticket id
* **create_ticket_comment**
  * Add a comment to a specific ticket.
    * **--use-defaults** "true"
      * Use the defaults instead of getting prompts. If you don't want to supply project name
* **update_ticket_status**
  * Update a specific tickets status.
* **ssh**
  * Options
    * **--use-sudo** "true|false"
      * If you want the command to run under sudo i.e. sudo ssh ..
    * **--host** "ip_address"
      * The host you want to connect to
    * **--connection-string-options** "-p 4000"
      * A string of options that will be added onto the command
    * **--commands 'command1;command2'**
      * A list of commands either a string array "["command1", "command2"]" or "command1;command2" or put string into toolshedrc file and call it "main_server_commands"
    * **--password "password1"**
      * The password you are using to login to the server
    * **--prompt-for-password "true|false"**
      * If you want to be more secure and just prompt for passwords
    * **--user "username"**
      * The user you want to connect with
    * **--keys "path/to/file"**
      * IdentityFile you want to use for authentication if passed no password will be asked
    * **--sudo-password "password1"**
      * If you need to use sudo provide a sudo password this can be taken from toolshedrc file also
    * **--verbose-output "true|flase"**
      * If you want to see commands being ran and other verbose output set this flag to true

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
