defmodule Mail.Templates do
  require EEx
  EEx.function_from_file :def, :common, "data/mailtemplates/common.eex", [:title, :content]
  EEx.function_from_file :def, :collab_notification_html, "data/mailtemplates/collab_notification.html.eex", [:name, :entered_name, :design_name, :id, :basename]
  EEx.function_from_file :def, :collab_notification_text, "data/mailtemplates/collab_notification.txt.eex", [:name, :entered_name, :design_name, :id, :basename]
  EEx.function_from_file :def, :notification_wk1, "data/mailtemplates/to_design_wk1.html.eex", 
  [:cookie, :basename]
  EEx.function_from_file :def, :collab_wk2, "data/mailtemplates/collab_wk2.html.eex", 
  [:id, :basename]
  EEx.function_from_file :def, :group_email, "data/mailtemplates/group_email.html.eex", 
  [:content, :nick, :id, :basename]
end
