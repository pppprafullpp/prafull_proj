class Api::V1::AccountReferralsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
	end

	def create
		if params[:referral_code].present? && params[:referrer_id].present?
			params[:referral_id] = AppUser.find_by_referral_code(params[:referral_code]).try(:id)
			account_referral = AccountReferral.new(account_referral_params)
			if account_referral.save
				app_user = AppUser.find_by_id(params[:referrer_id])
				app_user.refer_status = true
				app_user.save
				gift_received = account_referral.referrer_gift_coins
				message = "Congratulations!! You have earned #{account_referral.referrer_gift_coins}" 
				render 	:status => 200,
		        		:json => {
		                     	:success => true,
		                     	:gift => gift_received,
		                     	:message => message
		                     }
			else
				if account_referral.errors.full_messages[0] == "Referrer has already been taken"
					message = "Referral Id is already used."
					render :json => { :success => false, :message => message }
				else
					render :json => { :success => false }
				end
			end
		end

	end

	private
	def account_referral_params
		params.permit(:referral_id,:referrer_id,:referral_gift_coins,:referrer_gift_coins)
	end

end

