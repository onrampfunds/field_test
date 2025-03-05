module FieldTest
  class Membership < ActiveRecord::Base
    self.table_name = "field_test_memberships"

    has_many :events, class_name: "FieldTest::Event", foreign_key: "field_test_membership_id"

    unless FieldTest.legacy_participants
      belongs_to :participant, polymorphic: true, optional: true
    end

    validates :participant, presence: true, if: -> { FieldTest.legacy_participants }
    validates :participant_id, presence: true, if: -> { !FieldTest.legacy_participants }
    validates :experiment, presence: true
    validates :variant, presence: true

    # This is a workaround to support subclasses of ActiveRecord models (STI)
    # See: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#label-Polymorphic+Associations
    def participant_type=(class_name)
      return super(class_name) if class_name.blank?

      super(class_name.constantize.base_class.to_s)
    end
  end
end
