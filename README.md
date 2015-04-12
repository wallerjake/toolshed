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
