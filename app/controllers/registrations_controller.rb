# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  # redirect to entries page after sign up
  def after_sign_up_path_for(_resource)
    entries_path
  end

  def create
    super

    # if new user passes a valid invite uuid, associate them to league
    return unless resource.save && params[:invite_uuid]

    leagues = League.where(invite_uuid: params[:invite_uuid])
    return unless leagues.any?

    league = leagues.first
    LeagueUser.create!(user: resource, league:)
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
