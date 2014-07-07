class MailBot < ActionMailer::Base
  SITE_FROM_ADDRESS = 'noreply@pdxruby.org'
  SUBJECT_PREFIX = '[pdxruby] '

  helper ActionView::Helpers::UrlHelper

  # New user signup message
  def signup_message(ctrl, member)
     self.site_headers(member, "Account signup")
     @body = { :controller => ctrl, :member => member }
  end

  # Reset password e-mail
  def reset_password(ctrl, member, pass)
    self.site_headers(member, "Password Reset")
    @body = { :controller => ctrl, :member => member, :password => pass}
  end

  # Notify event owner of new feedback
  def feedback_message(ctrl, event)
     self.site_headers(event.member, "Feedback added for event #{event.name}")
     @body = { :controller => ctrl, :event => event }
  end

  # Notify all event participants of changes to event details
  def change_message(ctrl, event)
     rcpt = event.participants.map {|p| p.member}
     self.site_headers(rcpt, "Event #{event.name} details changed")
     @body = { :controller => ctrl, :event => event }
  end

  # Notify all event participants of event cancellation
  def cancel_message(ctrl, event)
     rcpt = event.participants.map {|p| p.member}
     self.site_headers(rcpt, "Event #{event.name} has been cancelled")
     @body = { :controller => ctrl, :event => event }
  end

  # Notify event owner of RSVP for their event
  def rsvp_message(ctrl, participant)
     event = participant.event
     self.site_headers(event.member, "New participant signup for event #{event.name}")
     @body = { :controller => ctrl, :participant => participant }
  end

  # Notify event owner of new feedback
  def feedback_message(ctrl, feedback)
     event = feedback.participant.event
     self.site_headers(event.member, "New feedback for event #{event.name}")
     @body = { :controller => ctrl, :feedback => feedback }
  end

  # the deliver_new_event_message method should be called seperately for
  # each site member (i.e., within a Member.find(:all) { ... } block) to
  # avoid exposing all member email addresses
  def new_event_message(ctrl, member, event)
     self.site_headers(member, "New event created")
     @body = { :controller => ctrl, :event => event, :member => member }
  end

  def site_headers(rcpt, subj)
     @recipients = rcpt.respond_to?(:map) ? rcpt.map {|m| m.email } : rcpt.email
     @from = SITE_FROM_ADDRESS
     @subject = SUBJECT_PREFIX + subj
  end
end
