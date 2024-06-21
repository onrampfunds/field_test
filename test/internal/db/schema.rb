ActiveRecord::Schema.define do
  create_table :field_test_memberships do |t|
    t.string :participant_type
    t.string :participant_id
    t.string :experiment
    t.string :variant
    t.datetime :created_at
    t.boolean :converted, default: false
    t.json :properties, default: {}, null: false
  end

  add_index :field_test_memberships, [:participant_type, :participant_id, :experiment], unique: true, name: "index_field_test_memberships_on_participant"
  add_index :field_test_memberships, [:experiment, :created_at]

  create_table :field_test_events do |t|
    t.references :field_test_membership
    t.string :name
    t.datetime :created_at
  end

  create_table :users do |t|
  end
end
