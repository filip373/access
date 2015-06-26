class AccountCreationNotifierMailer < ApplicationMailer
  def new_account(login, account_details)
    @login = login
    @email = account_details[:email]
    @password = account_details[:password]
    @codes = account_details[:codes]
    @account_using_instruction = AppConfig.google.email.account_using_instruction.split("\n")
    mail(to: AppConfig.office_email,
         subject: 'New Google Account has been created') do |format|
      format.html
      format.text
    end
  end
end
