class Channel < ActiveRecord::Base
  validates_uniqueness_of :channel_name, :channel_code
  CATEGORIES = ['Sports','News','Entertainment','Movies','Knowledge','Cartoon','Rituals','Music & Audio','Regional','Others']
  CHANNEL_TYPES = ['normal','adult','children']

  def self.get_channels
    self.where(:status => true)
  end

end
