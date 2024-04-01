require_relative "test_helper"

class FieldTestTest < Minitest::Test
  include Minitest::Hooks

  def after_all
    reset_config
  end

  def test_test_experiment_not_present_for_production_environment
    Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
      load_test_config
      refute FieldTest.config["experiments"].key?("test_experiment")
    end
  end

  def test_exclude_bots_present_for_production_environment
    Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
      load_test_config
      assert FieldTest.config["exclude_bots"]
    end
  end

  def test_test_experiment_present_for_test_environment
    Rails.stub(:env, ActiveSupport::StringInquirer.new("test")) do
      load_test_config
      assert FieldTest.config["experiments"].key?("test_experiment")
    end
  end

  def test_exclude_bots_present_for_test_environment
    Rails.stub(:env, ActiveSupport::StringInquirer.new("test")) do
      load_test_config
      assert FieldTest.config["exclude_bots"]
    end
  end

  def test_no_experiments_for_development_environment
    Rails.stub(:env, ActiveSupport::StringInquirer.new("development")) do
      load_test_config
      assert FieldTest.config["experiments"].nil?
    end
  end

  def test_exclude_bots_present_for_development_environment
    Rails.stub(:env, ActiveSupport::StringInquirer.new("development")) do
      load_test_config
      assert FieldTest.config["exclude_bots"]
    end
  end

  def test_raises_when_config_not_found_for_environment
    Rails.stub(:env, ActiveSupport::StringInquirer.new("unknown")) do
      assert_raises(FieldTest::MissingConfig) do
        load_test_config
      end
    end
  end

  private
    
  def reset_config
    FieldTest.instance_variable_set(:@config, nil)
  end
  
  def load_test_config
    reset_config
    FieldTest.stub(:config_path, Pathname.new("test/fixtures/multiple_environments_field_test_config.yml")) do
      FieldTest.config
    end
  end
end
