class Notification < ActionMailer::Base
  default :from => "\"CampusWise\" <info@campuswise.com>"

  def activation_needed_email(user)
    @user = user
    @url  = activate_user_url(user.activation_token)
    headers['X-SMTPAPI'] = "{\"category\" : \"Activation Needed\"}"
    mail(:to      => user.email,
      :subject => "Welcome to CampusWise")
  end

  def activation_success_email(user)
    @user = user
    @url  = login_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Welcome Email\"}"
    mail(:to => user.email,
      :subject => "Your account is now activated - CampusWise")
  end

  def reset_password_email(user)
    @user = user
    @url  = edit_password_reset_url(user.reset_password_token)
    headers['X-SMTPAPI'] = "{\"category\" : \"Password Help\"}"
    mail(:to => user.email,
      :subject => "Your password reset instructions - CampusWise")
  end

  def notify_book_borrower_failed_to_charge(exchange)
    @exchange = exchange
    @user = exchange.user
    @book = exchange.book
    @message = exchange.declined
    headers['X-SMTPAPI'] = "{\"category\" : \"Card Error Alert\"}"
    mail(:to => @user.email,
      :subject => "#{@exchange.package == "buy" ? "Purchase" : "Borrow"}  request failed - CampusWise")
  end

  def notify_book_owner(exchange)
    @user = exchange.book.user
    @borrower  = exchange.user
    @book = exchange.book
    @exchange = exchange
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "You have received a book #{@exchange.package == "buy" ? "purchase" : "borrow"} request - CampusWise")
  end

  def notify_book_borrower_accept(exchange)
    @exchange = exchange
    @user = exchange.user
    @book = exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Your #{@exchange.package == "buy" ? "purchase" : "borrow"} request has been accepted by the book #{@exchange.package == "buy" ? "seller" : "lender"} - CampusWise")
  end

  def notify_book_borrower_reject_by_user(exchange)
    @exchange = exchange
    @user = exchange.user
    @owner  = exchange.book.user
    @book = exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Your book #{@exchange.package == "buy" ? "purchase" : "borrow"}  request was rejected by the #{@exchange.package == "buy" ? "seller" : "lender"} - CampusWise")
  end

  def borrower_about_owner_doesnt_want_to_negotiate(exchange, requested_price)
    @requested_price = requested_price
    @exchange = exchange
    @user = exchange.user
    @owner  = exchange.book.user
    @book = exchange.book
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert - Negotiation\"}"
    mail(:to => @user.email,
      :subject => "#{@exchange.package == "buy" ? "Seller" : "Lender"} doesn't want to negotiate - CampusWise")
  end

  def borrower_about_owner_want_to_negotiate(exchange)
    @exchange = exchange
    @user = exchange.user
    @owner  = exchange.book.user
    @book = exchange.book
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert - Negotiation\"}"
    mail(:to => @user.email,
      :subject => "#{@exchange.package == "buy" ? "Seller" : "Lender"} want to negotiate - CampusWise")
  end

  def owner_about_borrower_want_to_negotiate(exchange)
    @exchange = exchange
    @user = exchange.book.user
    @borrower  = exchange.user
    @book = exchange.book
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert - Negotiation\"}"
    mail(:to => @user.email,
      :subject => "#{@exchange.package == "buy" ? "Buyer" : "Borrower"} want to negotiate - CampusWise")
  end

  def owner_about_negotiation_failed(exchange)
    @exchange = exchange
    @user = exchange.book.user
    @borrower  = exchange.user
    @book = exchange.book
    @url = login_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert - Negotiation\"}"
    mail(:to => @user.email,
      :subject => "#{@exchange.package == "buy" ? "Buyer" : "Borrower"} cancelled the request - CampusWise")
  end

  def notify_book_borrower_reject_for_payment(exchange)
    @exchange = exchange
    @user = exchange.user
    @owner  = exchange.book.user
    @book = exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Your book #{@exchange.package == "buy" ? "purchase" : "borrow"} request was rejected due to your card error - CampusWise")
  end

  def email_after_payment(payment)
    @exchange = payment.exchange
    @user = payment.exchange.user
    @book = payment.exchange.book
    @amount = payment.payment_amount.to_f
    headers['X-SMTPAPI'] = "{\"category\" : \"Payment Alert\"}"
    mail(:to => @user.email,
      :subject => "Your payment was successfully received - CampusWise")
  end

  def notify_book_borrower_exchange_successfull(payment)
    @user = payment.exchange.user
    @owner = payment.exchange.book.user
    @book = payment.exchange.book
    @exchange = payment.exchange
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Congratulation Your #{@exchange.package == "buy" ? "purchase" : "borrow"} request is now complete - CampusWise")
  end

  def notify_book_owner_exchange_successfull(payment)
    @user = payment.exchange.book.user
    @borrower = payment.exchange.user
    @book = payment.exchange.book
    @exchange = payment.exchange
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Congratulation Your Book #{@exchange.package == "buy" ? "selling" : "lending"}  process is complete - CampusWise")
  end

  def send_reminder_email_to_borrower(payment)
    @owner = payment.exchange.book.user
    @user = payment.exchange.user
    @book = payment.exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Reminder Alert\"}"
    mail(:to => @user.email,
      :subject => "Please return the book \"#{@book.title.truncate(20)}\" - CampusWise")
  end

  def send_reminder_email_to_lender(payment)
    @user = payment.exchange.book.user
    @borrower = payment.exchange.user
    @book = payment.exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Reminder Alert\"}"
    mail(:to => @user.email,
      :subject => "Please inform when the book \"#{@book.title.truncate(20)}\" is returned - CampusWise")
  end

  def notify_user_for_withdraw(withdraw_request)
    @user = withdraw_request.user
    @request = withdraw_request
    @amount = @request.amount.to_f
    headers['X-SMTPAPI'] = "{\"category\" : \"Withdraw Request\"}"
    mail(:to => @user.email,
      :subject => "Congratulations! Your withdraw request has been completed. -Campuswise")
  end

  def owner_full_price_charged(exchange)
    @book = exchange.book
    @user = @book.user
    @url = login_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Full book price charge\"}"
    mail(:to => @user.email,
      :subject => "Payment complete for you non-returned book -Campuswise")
  end

  def borrower_full_price_charged(exchange)
    @book = exchange.book
    @exchange = exchange
    @user = exchange.user
    headers['X-SMTPAPI'] = "{\"category\" : \"Full book price charge\"}"
    mail(:to => @user.email,
      :subject => "We charged you for not returning a book -Campuswise")
  end

  def owner_dropped_off_the_book(exchange)
    @book = exchange.book
    @exchange = exchange
    @user = exchange.user
    headers['X-SMTPAPI'] = "{\"category\" : \"Book dropped-off\"}"
    mail(:to => @user.email,
      :subject => "Owner dropped off the book '#{@book.title.truncate(30)}' to you - CampusWise")
  end

  def borrower_received_the_book(exchange)
    @book = exchange.book
    @exchange = exchange
    @user = exchange.book.user
    headers['X-SMTPAPI'] = "{\"category\" : \"Book received\"}"
    mail(:to => @user.email,
      :subject => "#{exchange.package == 'buy' ? 'Buyer' : 'Borrower'} received the book '#{@book.title.truncate(30)}' from you - CampusWise")
  end

  def offering_a_requested_book(requested_book_id, added_book_id)
    @requested_book = Book.find(requested_book_id)
    @added_book = Book.find(added_book_id)
    @user = @requested_book.user
    headers['X-SMTPAPI'] = "{\"category\" : \"Offering requested book\"}"
    mail(:to => @user.email,
      :subject => "Someone is offering your requested book '#{@requested_book.title.truncate(30)}'.- CampusWise")
  end
end
