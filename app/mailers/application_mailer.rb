# frozen_string_literal: true

# Base mailer class that all application mailers inherit from.
# Defines common configuration like default sender address and layout
class ApplicationMailer < ActionMailer::Base
    default from: 'from@example.com'
    layout 'mailer'
end
