module JavascriptHelper
  def page_replace(selector, *render_attr)
    %{
      $("#{selector}").replaceWith("#{escape_javascript(render *render_attr) }");
    }.html_safe
  end

  def page_replace_html(selector, *render_attr)
    %{
      $("#{selector}").html("#{escape_javascript(render *render_attr) }");
    }.html_safe
  end

  def open_modal(name, partial)
    %{
      $('body').append("#{escape_javascript(render :partial => partial, :layout => 'layouts/modal', :locals => {:modal_id => name}) }");
    }.html_safe
  end
end