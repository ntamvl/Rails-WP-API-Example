class MovieCategory < ActiveRecord::Base
  self.table_name = "mnc_category"

  has_many :movies, :foreign_key => :category
end