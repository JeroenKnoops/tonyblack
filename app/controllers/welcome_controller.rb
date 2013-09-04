class WelcomeController < ApplicationController
  def index
    @soundcloud_ids = Soundcloud.all.map &:soundcloud_id
  end
end
