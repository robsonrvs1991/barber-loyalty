class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Loy <no-reply@loy.app>")
  layout "mailer"
end
