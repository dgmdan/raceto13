class UserMailer < ApplicationMailer
  default from: 'MLB Runs Pool <runspool@danmadere.com>'

  def hit_email(hit)
    @hit = hit
    @url  = standings_url
    mail(to: @hit.entry.user.email, subject: "Congrats! Your team scored #{@hit.runs} runs")
  end

  def win_email(entry, winner_count)
    @entry = entry
    @url  = standings_url
    @winner_count = winner_count
    mail(to: @entry.user.email, subject: "CONGRATS! You're a winner")
  end
end
