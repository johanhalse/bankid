# frozen_string_literal: true

class LoginsController < ApplicationController
  def destroy
    result = Bankid.cancel(params[:id])
    redirect_to root_path, notice: "Login cancelled."
  end

  def show
    @bankid_secret, result = Bankid.collect(params[:id])

    return render "signatures/show" if result.pending?

    if result.success?
      create_login!(result.user, result.device)
      redirect_to root_path, notice: "Login successful!"
    else
      redirect_to root_path, notice: Bankid.translated_hint_code(result.hint_code)
    end
  end

  def new
    order_ref = Bankid.generate_authentication(ip: request.remote_ip, visible_data: "Please login!")
    redirect_to login_path(order_ref)
  end

  private

  def create_login!(user, _device)
    Signature.create!(name: user.name, uid: user.personal_number, device: "{}")
  end
end
