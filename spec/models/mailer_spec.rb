require File.dirname(__FILE__) + '/../spec_helper'

describe Mailer do
  it "sends an email on deliver_signup_notification" do
    @user = stub_model(User)
    lambda do
      Mailer.deliver_signup_notification(@user)
    end.should change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends a multipart email on deliver_signup_notification" do
    @user = stub_model(User)
    Mailer.deliver_signup_notification(@user)
    mail = ActionMailer::Base.deliveries.first
    mail.content_type.should == "multipart/alternative"
  end

  it "sends an email on password_reset_notification" do
    @user = stub_model(User)
    lambda do
      Mailer.deliver_password_reset_notification(@user)
    end.should change { ActionMailer::Base.deliveries.size }.by(1)
  end

end