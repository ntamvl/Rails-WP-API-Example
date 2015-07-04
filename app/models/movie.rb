class Movie < ActiveRecord::Base
  self.table_name = "mnc_movie"
  has_many :videos, :foreign_key => :movie
  belongs_to :movie_category, :foreign_key => :category
end