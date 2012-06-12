class Page < Cmspage

  has_many :cmspage_versions, :foreign_key => "cmspage_id", :order => "id DESC"

  before_update do |r|
    r.cmspage_versions.create({:content => r.description_was}) if r.description_changed?
  end

  def link
    "/#{self.page_url}"
  end

end