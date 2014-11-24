class Post < ActiveRecord::Base
  DB_MAGIC_DEFAULT_PARAMS = { :slave => :slave01, :force_slave_reads => false }
  db_magic DB_MAGIC_DEFAULT_PARAMS

  belongs_to :user
  has_and_belongs_to_many :categories

  scope :windows_posts, -> { where("title like '%win%'") }
  scope :dummy_scope, -> { where('1 = 1') }
end
