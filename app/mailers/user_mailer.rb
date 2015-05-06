class UserMailer < ApplicationMailer
  default from: 'MLB Runs Pool <runspool@danmadere.com>'

  def hit_email(hit)
    @hit = hit
    mail(to: @hit.entry.user.email, subject: "Congrats! Your team scored #{@hit.runs} runs")
  end

  def win_email(entry, winner_count)
    @entry = entry
    @winner_count = winner_count
    mail(to: @entry.user.email, subject: 'CONGRATS! You\'re a winner in the runs pool')
  end

  def conclusion_email(entry, winners)
    @winners = winners
    @entry = entry
    mail(to: @entry.user.email, subject: 'The runs pool has ended')
  end
end
