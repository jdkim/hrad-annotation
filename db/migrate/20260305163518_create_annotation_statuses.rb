class CreateAnnotationStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :annotation_statuses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :medical_case, null: false, foreign_key: true
      t.boolean :done, default: false, null: false

      t.timestamps
    end

    add_index :annotation_statuses, [ :user_id, :medical_case_id ], unique: true
  end
end
