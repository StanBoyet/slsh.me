class RecordVisitJob < ApplicationJob
  queue_as :default

  def perform(link_id, ip, user_agent, referer)
    link = Link.find_by(id: link_id)
    return unless link

    VisitTrackerService.new(
      link:       link,
      ip:         ip,
      user_agent: user_agent,
      referer:    referer
    ).call
  end
end
