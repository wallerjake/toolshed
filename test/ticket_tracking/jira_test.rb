require 'helper'
require 'toolshed/ticket_tracking/ticket_tracking'
require 'toolshed/ticket_tracking/jira'

class JiraTest < Test::Unit::TestCase
  def self.startup
    Toolshed::Client.instance.ticket_tracker_username = 'sample'
    Toolshed::Client.instance.ticket_tracker_password = 'sample'
    Toolshed::Client.instance.ticket_tracker_owner = 'sample'
    Toolshed::Client.instance.default_pull_request_title_format = '[id] - [summary]'
  end

  def test_add_note
    mock_init
    jira_init

    jira_comments_mock = mock('JIRA::HasManyProxy')
    jira_comments_mock.stubs({
      parent: @jira_issue_mock
    })

    @jira_issue_mock.expects(:comments).returns(
      jira_comments_mock
    )

    jira_comment_build_mock = mock('JIRA::Resource::Comment')
    jira_comment_build_mock.stubs({
      parent: @jira_issue_http_mock
    })

    jira_comments_mock.expects(:build).returns(
      jira_comment_build_mock
    )

    jira_comment_build_mock.expects(:save).with({ 'body' => 'This is my note' }).returns(
      true
    )

    assert(@jira.add_note('This is my note'))
  end

  def test_available_statuses
    mock_init
    jira_init
    available_statuses_mock

    assert_equal(@jira.available_statuses, @jira_find_all_mock)
  end

  def test_update_ticket_status
    mock_init
    jira_init
    available_statuses_mock

    jira_transitions_mock = mock('JIRA::HasManyProxy')
    jira_transitions_mock.stubs({
      parent: @jira_issue_http_mock
    })

    @jira_issue_mock.expects(:transitions).returns(
      jira_transitions_mock
    )

    jira_transition_build_mock = mock('JIRA::Resource::Transition')
    jira_transition_build_mock.stubs(
      :true
    )

    @jira.expects(:transition_status_id_by_status).with('Code Review').returns('1')

    jira_transitions_mock.expects(:build).returns(
      jira_transition_build_mock
    )

    jira_transition_build_mock.expects(:save).with({ 'transition' => { 'id' => '1' } }).returns(true)


    assert(@jira.update_ticket_status('Code Review'))
  end

  def test_transition_status_id_by_status
    mock_init
    jira_init

    jira_status = Struct.new(:id, :name)
    object_1 = jira_status.new(1, 'Code Review')
    object_2 = jira_status.new(2, 'In Development')

    @jira.expects(:available_statuses).returns(
      [
        object_1,
        object_2
      ]
    )

    assert('1', @jira.transition_status_id_by_status('Code Review').to_s)
  end

  def test_transition_status_id_by_status_should_raise_error
    mock_init
    jira_init

    jira_status = Struct.new(:id, :name)
    object_1 = jira_status.new(1, 'Code Review')
    object_2 = jira_status.new(2, 'In Development')

    @jira.expects(:available_statuses).returns(
      [
        object_1,
        object_2
      ]
    )

    assert_raise('Unable to find available status') { @jira.transition_status_id_by_status('bla') }
  end

  def test_url
    mock_init
    jira_init

    @jira_issue_mock.expects(:key).returns(
      '11'
    )

    assert_equal("https://#{Toolshed::Client.instance.ticket_tracker_owner}.atlassian.net/browse/11", @jira.url)
  end

  def test_username
    assert_equal(Toolshed::TicketTracking::Jira.username, Toolshed::Client.instance.ticket_tracker_username)
  end

  def test_password
    assert_equal(Toolshed::TicketTracking::Jira.password, Toolshed::Client.instance.ticket_tracker_password)
  end

  def test_create_instance_raise_project_name
    assert_raise('Unable to use Jira as project name was not supplied') { Toolshed::TicketTracking::Jira.create_instance() }
  end

  def test_create_instance_raise_ticket_id
    assert_raise('Unable to use Jira as ticket id was not supplied') { Toolshed::TicketTracking::Jira.create_instance({ project: 11 }) }
  end

  def test_default_pull_request_format_is_correct
    mock_init
    jira_init

    @jira_issue_mock.expects(:id).returns(
      '10'
    )

    @jira_issue_mock.expects(:summary).returns(
      'testing this out'
    )

    assert_equal "10 - testing this out", @jira.default_title
  end

  private

    def jira_init
      @jira = Toolshed::TicketTracking::Jira.create_instance({
        username: Toolshed::Client.instance.ticket_tracker_username,
        password: Toolshed::Client.instance.ticket_tracker_password,
        owner:    Toolshed::Client.instance.ticket_tracker_owner,
        project:  'project',
        ticket_id: '11',
      })
    end

    def mock_init
      #
      # Client MOCK
      #
      @jira_http_client = mock('JIRA::HttpClient')
      @jira_http_client.stubs(jira_http_mock_attributes)

      @jira_client_mock = mock('JIRA::Client')

      mock_options = jira_http_mock_attributes.merge!({ request_client: @jira_http_client})
      @jira_client_mock.stubs(mock_options)

      JIRA::Client.expects(:new).
      with({
        username: Toolshed::Client.instance.ticket_tracker_username,
        password: Toolshed::Client.instance.ticket_tracker_password,
        site: "https://#{Toolshed::Client.instance.ticket_tracker_owner}.atlassian.net",
        context_path: '',
        auth_type: :basic,
        use_ssl: true
      }).
      returns(@jira_client_mock)

      #
      # Project MOCK
      #
      @jira_project_http_mock = mock('JIRA::HttpClient')
      @jira_project_http_mock.stubs(jira_http_mock_attributes)

      @jira_project_mock = mock('JIRA::Resource::ProjectFactory')
      @jira_project_mock.stubs({
        :client => @jira_client_mock,
        :request_client => @jira_project_http_mock
      })

      @jira_client_mock.expects(:Project).returns(
        @jira_project_mock
      )

      @jira_project_mock.expects(:find).with('project').returns(
        @jira_project_mock
      )

      #
      # Issue MOCK
      #
      @jira_issue_http_mock = mock('JIRA::HttpClient')
      @jira_issue_http_mock.stubs(jira_http_mock_attributes)

      @jira_issue_mock = mock('JIRA::Resource::IssueFactory')
      @jira_issue_mock.stubs({
        :client => @jira_client_mock,
        :request_client => @jira_project_http_mock
      })

      @jira_client_mock.expects(:Issue).returns(
        @jira_issue_mock
      )

      @jira_issue_mock.expects(:find).with('11').returns(
        @jira_issue_mock
      )
    end

    def jira_http_mock_attributes
      {
        options: {
          username:         Toolshed::Client.instance.ticket_tracker_username,
          password:         Toolshed::Client.instance.ticket_tracker_password,
          site:             "https://#{Toolshed::Client.instance.ticket_tracker_owner}.atlassian.net",
          context_path:     "",
          rest_base_path:   "/rest/api/2",
          ssl_verify_mode:  1,
          use_ssl:          true,
          auth_type:        :basic,
        }
      }
    end

    def available_statuses_mock
      jira_transition_mock = mock('JIRA::Resource::TransitionFactory')

      mock_options = jira_http_mock_attributes.merge!({ request_client: @jira_http_client})
      jira_transition_mock.stubs(
        mock_options
      )

      @jira_client_mock.expects(:Transition).returns(
        jira_transition_mock
      )

      @jira_find_all_mock = mock('JIRA::Resource::Transition')
      @jira_find_all_mock.stubs(
        {
          id: 1,
          name: 'Code Review',
        },
        {
          id: 2,
          name: 'In Development',
        },
      )

      jira_transition_mock.expects(:all).with({ issue: @jira_issue_mock }).returns(
        @jira_find_all_mock
      )
    end
end
