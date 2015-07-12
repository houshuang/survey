defmodule Mail.Templates do
  require EEx
  EEx.function_from_file :def, :common, "data/mailtemplates/common.eex", [:title, :content]
  EEx.function_from_file :def, :collab_notification_html, "data/mailtemplates/collab_notification.html.eex", [:name, :entered_name, :design_name, :cookie, :basename]
  EEx.function_from_file :def, :collab_notification_text, "data/mailtemplates/collab_notification.txt.eex", [:name, :entered_name, :design_name, :cookie, :basename]
  EEx.function_from_file :def, :notification_wk1, "data/mailtemplates/to_design_wk1.html.eex", 
  [:cookie, :basename]
end
