class ApplicationMailer < ActionMailer::Base
  default from: AppConfig.office_email
  layout 'mailer'
end
