class PasswordSignupService < ApplicationService
  def initialize(first_name:, last_name:, email:, password:, nickname: nil)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @password = password
    @nickname = nickname
  end

  def call
    user = nil

    ActiveRecord::Base.transaction do
      person = Person.create!(first_name: @first_name, last_name: @last_name, nickname: @nickname)
      user = User.create!(person: person, email: @email, password: @password)
    end

    UserMailer.verification_email(user).deliver_later
    AuditLogger.log(action: "user.signed_up", actor_user: user, metadata: { method: "password" })

    ServiceResult.success(user)
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.failure(e.record.errors.full_messages)
  end
end
