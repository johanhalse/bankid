# frozen_string_literal: true

class SignaturesController < ApplicationController
  def index; end

  def show
    @bankid_secret, result = Bankid.collect(params[:id])

    return render if result.pending?

    if result.success?
      create_signature!(result.user, result.device)
      redirect_to root_path, notice: "Successfully signed!"
    else
      redirect_to root_path, notice: Bankid.translated_hint_code(result.hint_code)
    end
  end

  def new
    order_ref = Bankid.generate_signature(ip: request.remote_ip, visible_data: "You gotta sign this.")
    redirect_to signature_path(order_ref)
  end

  private

  def create_signature!(user, device)
    Signature.create!(name: user.name, uid: user.personal_number, device: device.to_json)
  end
end
