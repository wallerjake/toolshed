require 'helper'

def create_and_checkout_branch(name, branch_from='master')
  save_stash

  until system("git checkout -b #{name} origin/#{branch_from}")
    sleep 1
  end
end

def pop_stash
  system("git stash pop")
end

def save_stash
  system("git stash save")
end

def delete_branch(branch_name)
  until system("git branch -D #{branch_name} --quiet")
    sleep 1
  end
end
