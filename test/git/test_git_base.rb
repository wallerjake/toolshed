require 'helper'

def create_and_checkout_branch(name, branch_from='master')
  save_stash
  cb = `git checkout -b #{name} origin/#{branch_from}`
end

def pop_stash
  stash = `git stash pop`
end

def save_stash
  stash = `git stash save`
end

def delete_branch(branch_name)
  db = `git branch -D #{branch_name}`
end
