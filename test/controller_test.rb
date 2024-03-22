require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  def setup
    FieldTest::Membership.delete_all
    User.delete_all
  end

  def test_no_user
    get users_url
    assert_response :success

    membership = FieldTest::Membership.last
    assert_equal 1, FieldTest::Membership.count
    assert membership.converted
    assert_nil membership.participant_type
    assert membership.participant_id
  end

  def test_user
    user = User.create!

    get users_url
    assert_response :success

    membership = FieldTest::Membership.last
    assert_equal 1, FieldTest::Membership.count
    assert membership.converted
    assert_equal "User", membership.participant_type
    assert_equal user.id.to_s, membership.participant_id
  end

  def test_param
    get users_url("field_test[button_color]" => "green")
    assert_response :success

    assert_includes response.body, "Button: green"
    assert_equal 0, FieldTest::Membership.count
  end

  def test_bad_param
    get users_url("field_test[button_color]" => "bad")
    assert_response :success

    refute_includes response.body, "Button: bad"
  end

  def test_exclude_custom_logic
    get exclude_url(exclude: true)
    assert_response :success

    assert_equal 0, FieldTest::Membership.count

    get exclude_url
    assert_response :success

    assert_equal 1, FieldTest::Membership.count
  end

  def test_exclude_bots
    get users_url, headers: {"HTTP_USER_AGENT" => "Googlebot"}
    assert_response :success

    assert_equal 0, FieldTest::Membership.count
  end

  def test_exclude_ips
    get users_url, headers: {"HTTP_X_FORWARDED_FOR" => "123.4.5.6"}
    assert_response :success

    assert_equal 0, FieldTest::Membership.count
  end

  def test_exclude_ips_range
    get users_url, headers: {"HTTP_X_FORWARDED_FOR" => "123.1.2.3"}
    assert_response :success

    assert_equal 0, FieldTest::Membership.count
  end

  def test_field_test_upgrade_memberships_when_duplicate_merges_it
    user = User.create!

    membership1 = FieldTest::Membership.create!(
      experiment: "landing_page4",
      participant_type: "User", 
      participant_id: user.id,
      variant: "control",
      converted: true
    )
    membership2 = FieldTest::Membership.create!(
      experiment: "landing_page4",
      participant_type: nil, 
      participant_id: "visitor_token",
      variant: "variant",
      converted: true
    )

    membership1.events.create!(name: "signed_up")
    membership2.events.create!(name: "other_goal")

    get upgrade_memberships_when_duplicate_url

    assert_equal 1, FieldTest::Membership.count

    membership = FieldTest::Membership.last

    assert_equal "User", membership.participant_type
    assert_equal user.id.to_s, membership.participant_id
    assert_equal "control", membership.variant
    assert membership.converted
    assert_equal 2, membership.events.count
    assert_includes membership.events.pluck(:name), "signed_up", "other_goal"
  end

  def get(url, **options)
    options[:headers] ||= {}
    options[:headers]["HTTP_USER_AGENT"] ||= "Mozilla/5.0"
    super(url, **options)
  end
end
