require 'helper'
require 'toolshed/time_tracking/time_tracking'
require 'toolshed/time_tracking/harvest'

class HarvestTest < Test::Unit::TestCase
  def self.startup
    Toolshed::Client.instance.time_tracking_tool               = 'harvest'
    Toolshed::Client.instance.time_tracking_default_project_id = '1234'
    Toolshed::Client.instance.time_tracking_username           = 'sample_username'
    Toolshed::Client.instance.time_tracking_password           = 'sample1234'
    Toolshed::Client.instance.time_tracking_owner              = 'me'

    ::Harvest.expects(:client).
    with(subdomain: Toolshed::Client.instance.time_tracking_owner, username: Toolshed::Client.instance.time_tracking_username, password: Toolshed::Client.instance.time_tracking_password).
    returns('')
  end

  def test_get_previous_time_entries
    harvest_mock = mock('Harvest::TimeEntry')
    harvest_mock.stubs(:notes => 'Worked on this yesterday')

    second_time_entry_harvest_mock = mock('Harvest::TimeEntry')
    second_time_entry_harvest_mock.stubs(:notes => 'Second thing for the day')

    Toolshed::TimeTracking::Harvest.any_instance.stubs(:previous_time_entries).
    returns([harvest_mock, second_time_entry_harvest_mock])

    harvest = Toolshed::TimeTracking::Harvest.new()
    output = harvest.previous_notes

    assert_match /Worked on this yesterday/, output
    assert_match /Second thing for the day/, output
  end

  def test_get_todays_time_entries
    harvest_mock = mock('Harvest::TimeEntry')
    harvest_mock.stubs(:notes => 'Worked on this today')

    second_time_entry_harvest_mock = mock('Harvest::TimeEntry')
    second_time_entry_harvest_mock.stubs(:notes => 'Second thing for the day today')

    Toolshed::TimeTracking::Harvest.any_instance.stubs(:previous_time_entries).
    returns([harvest_mock, second_time_entry_harvest_mock])

    harvest = Toolshed::TimeTracking::Harvest.new()
    output = harvest.previous_notes

    assert_match /Worked on this today/, output
    assert_match /Second thing for the day today/, output
  end
end
