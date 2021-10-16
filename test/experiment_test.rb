require_relative "test_helper"

class ExperimentTest < Minitest::Test
  def setup
    FieldTest::Membership.delete_all
  end

  def test_winner
    experiment = FieldTest::Experiment.find(:landing_page)
    assert_equal experiment.winner, experiment.variant("user123")
    assert_equal 0, FieldTest::Membership.count
  end

  def test_winner_existing_participant
    experiment = FieldTest::Experiment.find(:landing_page)
    set_variant experiment, "page_a", "user123"
    assert_equal experiment.winner, experiment.variant("user123")

    # test no metrics
    results = experiment.results
    experiment.convert("user123")
    assert_equal results, experiment.results
  end

  def test_winner_keep_variant
    experiment = FieldTest::Experiment.find(:landing_page2)
    set_variant experiment, "page_a", "user123"
    assert_equal "page_a", experiment.variant("user123")
  end

  def test_closed
    experiment = FieldTest::Experiment.find(:landing_page3)
    assert_equal experiment.control, experiment.variant("user123")
    assert_equal 0, FieldTest::Membership.count
  end

  def test_closed_existing_participant
    experiment = FieldTest::Experiment.find(:landing_page3)
    set_variant experiment, "page_a", "user123"
    assert_equal "page_a", experiment.variant("user123")
  end

  def test_goals
    experiment = FieldTest::Experiment.find(:landing_page4)
    assert experiment.multiple_goals?
    assert_equal ["signed_up", "ordered"], experiment.goals

    set_variant experiment, "page_a", "user123"
    experiment.convert("user123", goal: "signed_up")

    result = experiment.results(goal: "signed_up")["page_a"]
    assert_equal 1, result[:participated]
    assert_equal 1, result[:converted]
    assert_equal 1, result[:conversion_rate]
    assert_in_delta 0.5, result[:prob_winning]

    result = experiment.results(goal: "ordered")["page_a"]
    assert_equal 1, result[:participated]
    assert_equal 0, result[:converted]
    assert_equal 0, result[:conversion_rate]
    assert_in_delta 0.166666666666667, result[:prob_winning]
  end

  def test_variants
    experiment = FieldTest::Experiment.find(:button_color)
    assert_equal ["red", "green", "blue"], experiment.variants
    assert_equal "red", experiment.control
  end

  def test_prob_winning_two_variants
    experiment = FieldTest::Experiment.find(:button_color2)
    50.times do |i|
      variant = i < 35 ? "red" : "green"
      set_variant experiment, variant, "user#{i}"
      experiment.convert("user#{i}") if i < 10 || i % 3 == 0
    end
    results = experiment.results
    assert_in_delta 0.8722609845723905, results["red"][:prob_winning]
    assert_in_delta 0.12773901542760946, results["green"][:prob_winning]
  end

  def test_prob_winning_three_variants
    experiment = FieldTest::Experiment.find(:button_color)
    50.times do |i|
      variant = i < 25 ? "red" : (i < 40 ? "green" : "blue")
      set_variant experiment, variant, "user#{i}"
      experiment.convert("user#{i}") if i < 10 || i % 3 == 0 || i > 47
    end
    results = experiment.results
    assert_in_delta 0.8156540600702418, results["red"][:prob_winning]
    assert_in_delta 0.04309667172308218, results["green"][:prob_winning]
    assert_in_delta 0.14124926820667605, results["blue"][:prob_winning]
  end

  def test_prob_winning_two_variants_no_participants
    experiment = FieldTest::Experiment.find(:button_color2)
    experiment.results.each do |_, v|
      assert_in_delta 0.5, v[:prob_winning]
    end
  end

  def test_prob_winning_three_variants_no_participants
    experiment = FieldTest::Experiment.find(:button_color)
    experiment.results.each do |_, v|
      assert_in_delta 0.3333333333333333, v[:prob_winning]
    end
  end

  private

  def set_variant(experiment, variant, participant_id)
    FieldTest::Membership.create!(
      experiment: experiment.id,
      variant: variant,
      participant_id: participant_id
    )
  end
end
