class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.string :content
      t.string :author
      t.references :article

      t.timestamps
    end
  end
end
