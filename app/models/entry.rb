# encoding: utf-8
class Entry
  include Mongoid::Document
  include Mongoid::Document::Taggable
  include Mongoid::Timestamps
  #include Mongoid::Commentable
  field :short, :type => String
  field :long,  :type => String

  mount_uploader :image, ImageUploader

  validates_presence_of :short
  attr_accessible :short, :long, :image, :image_cache, :tag_list

  def has_long?
  	self.long.length > 0
  end

  before_create :split_tags
  before_save :gsub_long
  def split_tags
    old_tags = self.tag_list
    new_tags = old_tags.split(" ").join(",").split("|").join(",")
    self.tag_list = new_tags
  end
  def gsub_long
    self.long = self.long.blank? ? "" : self.long.gsub(/\r\n/," \n").gsub(/ +/," ")
  end

  has_many :comments, :class_name => "NewComment", :as => :commentable
end