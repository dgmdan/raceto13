class RegistrationsController < Devise::RegistrationsController

  def create
    super

    # if new user passes a valid invite uuid, associate them to league
    if resource.save and params[:invite_uuid]
      leagues = League.where(invite_uuid: params[:invite_uuid])
      if leagues.any?
        league = leagues.first
        LeagueUser.create!(user: resource, league: league)
      end
    end
  end

  protected

  def update_resource(resource, params)
    if params[:password].blank?
      resource.update_without_password(params)
    else
      resource.update(params)
    end
  end
end