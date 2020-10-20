require 'draper'

Draper::ViewContext.test_strategy :fast do
  include ApplicationHelper
end
