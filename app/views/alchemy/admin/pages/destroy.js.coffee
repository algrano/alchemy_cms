$('#locked_page_<%= @page_id -%>').remove()

<% if @layoutpage %>

  window.location.replace '<%= alchemy.admin_layoutpages_path -%>'

<% elsif @page_root %>

  $('#sitemap').replaceWith '<%= escape_javascript(render(:partial => "sitemap")) -%>'
  Alchemy.growl '<%= @message -%>'
  Alchemy.Tooltips()

<% else %>

  window.location.replace '<%= alchemy.admin_pages_path -%>'

<% end %>

Alchemy.pleaseWaitOverlay false
