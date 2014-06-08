require 'helper'

def create_and_checkout_branch(name, branch_from='master')
  save_stash

  until system("git checkout -b #{name} origin/#{branch_from} #{Toolshed::Client.git_quiet}")
    sleep 1
  end

  until system("git push origin #{name} #{Toolshed::Client.git_quiet}")
    sleep 1
  end
end

def pop_stash
  system("git stash pop #{Toolshed::Client.git_quiet}")
end

def save_stash
  system("git stash save #{Toolshed::Client.git_quiet}")
end

def delete_branch(branch_name)
  until system("git branch -D #{branch_name} #{Toolshed::Client.git_quiet}")
    sleep 1
  end
end

def random_branch_name
  "#{::Faker::Lorem.word.downcase}_#{Time.now.to_i}"
end
