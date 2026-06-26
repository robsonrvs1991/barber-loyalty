class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Loy <noreply@loynow.com>")
  layout "mailer"
end