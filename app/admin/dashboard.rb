ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
#    div :class => "blank_slate_container", :id => "dashboard_default_message" do
#      span :class => "blank_slate" do
#        span I18n.t("active_admin.dashboard_welcome.welcome")
#        small I18n.t("active_admin.dashboard_welcome.call_to_action")
#      end
#    end

    columns do
      column do
        panel "Notifications" do
          if AdminUser.first.dashboard_notifications.any?
            AdminUser.first.dashboard_notifications.order("created_at desc").each do |notification|
              ul do
                li notification.content.html_safe
                para link_to "Remove", remove_notification_admin_book_path(notification.id)
              end
            end
          else
            para "No new notifications"
          end
        end
      end
    end
  end
end





#    columns do
#
#    end

# Here is an example of a simple dashboard with columns and panels.
#
# columns do
#   column do
#     panel "Recent Posts" do
#       ul do
#         Post.recent(5).map do |post|
#           li link_to(post.title, admin_post_path(post))
#         end
#       end
#     end
#   end

#   column do
#     panel "Info" do
#       para "Welcome to ActiveAdmin."
#     end
#   end
# end

