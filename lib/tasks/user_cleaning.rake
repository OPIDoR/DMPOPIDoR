# frozen_string_literal: true

namespace :usercleaning do
  desc 'Remove users who haven\'t accepted invitation after 1 month.'
  task non_accepted_invitations: :environment do
    Rails.logger.info 'Deleting user uncomfirmed users invited over a month ago'
    User
      .where('invitation_sent_at < ? AND invitation_accepted_at IS NULL AND current_sign_in_at IS NULL', 1.month.ago)
      .each do |user|
      p "#{user.email}  deleted"
      user.destroy
    end
  end

  desc 'Anonymize users who haven\'t been connected for five years.'
  task anonymize_users_after_5_years: :environment do
    Rails.logger.info 'Anonymizing users who have not connected for the last 5 years'
    users_to_process = User.where('active = true and current_sign_in_at < ?', 5.years.ago + 1.month)
    Rails.logger.info "#{users_to_process.count} users to anonymize"

    users_to_process.find_each do |user|
      next if user.current_sign_in_at.nil?

      deletion_date = (user.current_sign_in_at + 5.years).to_date
      case Date.today
      when (deletion_date - 1.month)
        p "Sending 1 month anonymization warning to #{user.email}"
        UserMailer.anonymization_warning(user).deliver_now
      when (deletion_date - 1.week)
        p "Sending 1 week anonymization warning to #{user.email}"
        UserMailer.anonymization_warning(user).deliver_now
      when (deletion_date - 1.day)
        p "Sending 1 day anonymization warning to #{user.email}"
        UserMailer.anonymization_warning(user).deliver_now
      else
        if Date.today >= deletion_date
          Rails.logger.info "Archiving user: #{user.id} #{user.email}"
          user.archive
        end
      end
    end
  end
end
