class UserMailer < ApplicationMailer
  default from: 'runspool@danmadere.com'

  def hit_email(hit)
    @entry = hit.entry
    @user = @entry.user
    @url  = 'http://marathonrunspool.com'
    mail(to: @user.email, subject: 'Congrats, you scored in the runs pool!')
  end
end
