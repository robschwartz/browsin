class User < ActiveRecord::Base
  has_many :user_preferences
  has_many :hidden_media, -> {where 'user_preferences.view_status'=> 'hide'}, through: :user_preferences, source: :media

  has_secure_password

  validates_presence_of :service_list, :email, :password, :on => :create
  validates_uniqueness_of :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :password, :length => { :minimum => 6 }

  acts_as_taggable_on :services

  def self.current
  	Thread.current[:user]
  end

  def self.current=(user)
  	Thread.current[:user] = user
  end

  def media
      Media.tagged_with(self.service_list, :any => true).where.not(imdb_id: self.hidden_media_ids)
  end

  def hidden_media_ids
    self.hidden_media.pluck(:imdb_id)
  end

end
