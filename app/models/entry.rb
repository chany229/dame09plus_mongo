# encoding: utf-8
class Entry
  include Mongoid::Document
  include Mongoid::Document::Taggable
  include Mongoid::Timestamps
  include Mongoid::Commentable
  field :short, :type => String
  field :long,  :type => String
  validates_presence_of :short

  def has_long?
  	self.long.length > 0
  end

end