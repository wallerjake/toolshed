require 'commands/commands_helper'
require 'toolshed/commands/get_daily_time_update'

class GetDailyTimeUpdateTest < Test::Unit::TestCase
  def self.startup
    Toolshed::Client.time_tracking_tool               = 'harvest'
    Toolshed::Client.time_tracking_default_project_id = '1234'
    Toolshed::Client.time_tracking_username           = 'sample_username'
    Toolshed::Client.time_tracking_password           = 'sample1234'
    Toolshed::Client.time_tracking_owner              = 'me'
  end

  def test_get_daily_time_update_with_defaults
    ::Harvest.expects(:client).
    with(subdomain: Toolshed::Client.time_tracking_owner, username: Toolshed::Client.time_tracking_username, password: Toolshed::Client.time_tracking_password).
    returns('')

    harvest_mock = mock('Harvest::TimeEntry')
    harvest_mock.stubs(:notes => 'Worked on this yesterday')

    Toolshed::TimeTracking::Harvest.any_instance.stubs(:previous_time_entries).
    returns([harvest_mock])

    harvest_mock = mock('Harvest::TimeEntry')
    harvest_mock.stubs(:notes => 'Worked on this')

    Toolshed::TimeTracking::Harvest.any_instance.stubs(:todays_time_entries).
    returns([harvest_mock])

    output = capture_stdout { Toolshed::Commands::GetDailyTimeUpdate.new.execute({}, { project_id: '1111' }) }
    assert_match /Worked on this yesterday/, output
    assert_match /Worked on this/, output
  end

  def test_get_daily_time_update_with_use_defaults_on
    Toolshed::Client.use_defaults                     = true

    ::Harvest.expects(:client).
    with(subdomain: Toolshed::Client.time_tracking_owner, username: Toolshed::Client.time_tracking_username, password: Toolshed::Client.time_tracking_password).
    returns('')

    harvest_mock = mock('Harvest::TimeEntry')
    harvest_mock.stubs(:notes => 'Worked on this yesterday')

    Toolshed::TimeTracking::Harvest.any_instance.stubs(:previous_time_entries).
    returns([harvest_mock])

    harvest_mock = mock('Harvest::TimeEntry')
    harvest_mock.stubs(:notes => 'Worked on this')

    Toolshed::TimeTracking::Harvest.any_instance.stubs(:todays_time_entries).
    returns([harvest_mock])

    output = capture_stdout { Toolshed::Commands::GetDailyTimeUpdate.new.execute({}, {}) }
    assert_match /Previous:/, output
    assert_match /Today:/, output   
    assert_match /Worked on this yesterday/, output
    assert_match /Worked on this/, output
  end
end
