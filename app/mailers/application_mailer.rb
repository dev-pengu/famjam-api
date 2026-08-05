class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_DEFAULT_FROM', 'no-reply@familyapp.example')
  layout 'mailer'
end