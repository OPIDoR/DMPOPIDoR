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
    five_years_users = User.where('active = true and current_sign_in_at < ?', 5.years.ago - 1.month)
    Rails.logger.info "#{five_years_users.count} users to anonymize"

    five_years_users.each do |user|
      last_sign_in = user.current_sign_in_at || 5.years.ago
      case Date.today
      when (last_sign_in + 5.years + 1.month).to_date
        p "Sending 1 month anonymization warning to #{user.email}"
        UserMailer.anonymization_warning(user).deliver_now
      when (last_sign_in + 5.years + 1.week).to_date
        p "Sending 1 week anonymization warning to #{user.email}"
        UserMailer.anonymization_warning(user).deliver_now
      when (last_sign_in + 5.years + 1.day).to_date
        p "Sending 1 day anonymization warning to #{user.email}"
        UserMailer.anonymization_warning(user).deliver_now
      else
        p "Archiving user: #{user.id} #{user.email}"
        user.archive # default should archive every other user : last log in > 5y
      end
    end
  end
end
