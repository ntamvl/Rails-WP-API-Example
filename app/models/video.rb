class Video < ActiveRecord::Base
  self.table_name = "mnc_video"
  belongs_to :movie, :foreign_key => :movie
end
