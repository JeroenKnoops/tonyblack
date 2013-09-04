module ApplicationHelper
  def soundcloud(sound_id)
    @sound_id = sound_id
    render 'shared/soundcloud'
  end
end
