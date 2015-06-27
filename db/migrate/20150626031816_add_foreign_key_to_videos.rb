class AddForeignKeyToVideos < ActiveRecord::Migration
  def change
    # add_column :videos, :movie, :string
    add_foreign_key :mnc_video, :mnc_movie, column:  :movie, primary_key: :code
  end
end
