ActiveAdmin.register_page "Mail Previews" do

  menu :parent => 'CMS'

  content do
    panel "Templates" do
        render 'index', :layout => 'active_admin'
    end
  end  
  
  sidebar :templates do
  end

end
