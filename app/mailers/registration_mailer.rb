class RegistrationMailer < Devise::Mailer
  layout 'user_email'
  helper 'application'

  default :from => SiteConfig.mailer_sender
  default :bcc  => SiteConfig.mail_bcc

  def welcome_instructions(user)
    @user      = user
    recipients = "#{user.full_name} <#{user.email}>"
    subject    = 'Welcome to SquareStays'

    mail(:to => recipients, :subject => subject)
  end
end