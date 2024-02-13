class PasswordStrategy < Warden::Strategies::Base

  def valid?
    !!params['password']
  end

  def authenticate!
    if params['password'] == Settings['admin_password']
      success! AdminUser.new
    else
      fail! 'Wrong password'
    end
  end

end
