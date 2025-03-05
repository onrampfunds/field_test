require_relative "test_helper"

class ModelTest < Minitest::Test
  def setup
    FieldTest::Membership.delete_all
  end

  def test_membership_with_event
    experiment = FieldTest::Experiment.find(:landing_page)
    membership = set_variant experiment, "page_a", "user123"
    event = FieldTest::Event.create!(
      name: "conversion",
      field_test_membership_id: membership.id
    )

    assert_equal membership, event.field_test_membership
    assert_equal 1, membership.events.count
    assert_equal event, membership.events.first
  end

  def test_participant_type_setter
    membership = FieldTest::Membership.new

    # Test blank case
    membership.participant_type = ""
    assert_equal "", membership.participant_type

    # Test nil case
    membership.participant_type = nil
    assert_nil membership.participant_type

    # Test with a regular class
    membership.participant_type = "User"
    assert_equal "User", membership.participant_type

    # Test with a subclass (should return base class)
    membership.participant_type = "User::Admin"
    assert_equal "User", membership.participant_type
  end
end
