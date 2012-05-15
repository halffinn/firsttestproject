class GalleryItem < ActiveRecord::Base
  
  belongs_to :gallery
  
  default_scope :order => 'position ASC'
  
  scope :active, where(:active => true)
  
  has_attached_file :photo, {
     :styles => {
       :large => {
         :geometry => "602x401>"
       },
       :tiny => "40x40#"
     },
     :convert_options => { 
        :all => "-quality 70"
      },
     :path => "front/photos/:id/:style.:extension",
     :processors => [:rationize, :watermark]
   }
   
   
   #Easy accessor to get the imageurl
   def image_url
     self.photo.url('large')
   end
   
  
end